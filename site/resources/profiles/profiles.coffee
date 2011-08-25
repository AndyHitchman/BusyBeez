{db, ObjectId} = require '../../modules/db.coffee'
crypto = require 'crypto'
querystring = require 'querystring'


exports.routes = (app) ->

  app.get '/profiles/new', middleware.signedIn, (req, res) ->
    return res.redirect __.returnToUrl req if req.user?

    res.render 'profiles/new',
      returnto: __.returnToUrl req
      model: {}


  app.post '/profiles/signin', (req, res) ->
    input = req.body
    if !input.email or !input.password
      req.flash 'error',
        "There's something wrong with the information you entered. Please enter your email address and password."
      return res.render 'profiles/new',
        returnto: __.returnToUrl req
        model: input

    db.collection('users').findOne {email: input.email, password: __.hashPassword input.password }, (err, doc) ->
      if !doc?
        req.flash 'error',
          "We don't know who you are. Please check you typed the right email address and password and try again."
        return res.render 'profiles/new',
          returnto: __.returnToUrl req
          model: input

      __.setSignedInUser req, doc
      res.redirect __.returnToUrl req


  app.post '/profiles/new', (req, res) ->
    input = req.body

    #Validate the input. We're relying on client side JS to help the user. This is a simple guard.
    if !input.firstName or !input.lastName or !input.suburbId or !input.email or
       !input.password or !input.confirmPassword
      req.flash 'error', "There's something wrong with the information you entered. Please check and try again"
      return res.render '/profiles/new',
        returnto: __.returnToUrl req
        model: input

    newUser =
      firstName:  input.firstName
      lastName:   input.lastName
      suburb:     input.suburb
      suburbId:   input.suburbId
      email:      input.email
      password:   input.password

    __.create newUser, (err) ->
      if err?.notUnique
        req.flash 'error',
          "We already have a profile with this email address. Is it yours? Try signing in or request a password reset."
        return res.render 'profiles/new',
          returnto: __.returnToUrl req
          model: input

      __.setSignedInUser req, newUser

      req.flash 'info',
        "Thanks #{newUser.firstName}! " +
        "We've logged you on and you're good to go! Please look for the confirmation email in your inbox."
      res.redirect __.returnToUrl req


  app.get '/profiles/confirm/:token', (req, res) ->
    __.confirmUserIdentity req.params.token, (confirmedUser) ->
      if confirmedUser?
        __.setSignedInUser req, confirmedUser
        req.flash 'info', "Thanks #{confirmedUser.firstName}! You've activated your profile."
        bus.emit 'profileActivated', confirmedUser
      return res.redirect 'home'



bus.on 'newUser', (user) ->
  console.log 'STUB' +
    " introductory email sent to " + user.email +
    " with confirmation link https://#{global.domainName}/profiles/confirm/#{user.confirmationToken}"



exports.middleware = middleware =
  # Route middleware provides the signed in user in req.user, or if not signed in
  # redirects to the sign-in route.
  mustBeSignedIn: (signInFlash) ->
    (req, res, next) ->
      middleware.signedIn req, res, (err) ->
        next err if err?
        if !req.user?
          #Redirect to create profile
          req.flash 'info', signInFlash ? "You must create a profile or be signed in to continue"
          return res.redirect __.signInUrl req

        next()

  # Route middleware provides the signed in user in req.user
  signedIn: (req, res, next) ->
    req.user = req.session.user
    next()



__ =
  signInUrl: (req) ->
    "/profiles/new?returnto=#{querystring.escape(req.url)}"

  returnToUrl: (req) ->
    querystring.unescape(req.param('returnto') ? '') ? 'home'

  setSignedInUser: (req, user) ->
    req.session.user =
      id: user._id
      firstName: user.firstName
      lastName: user.lastName
      email: user.email


  hashPassword: (plain) ->
    hash = crypto.createHash 'sha1'
    hash.update plain + "Charles Babbage"
    hash.digest 'base64'


  getById: (id) ->
    db.collection('users').findOne {_id: new ObjectId(id)}, (err, doc) ->
      throw new Error "Failed to load user " + id if err?
      doc


  confirmUserIdentity: (token, callback) ->
    db.collection('users').findOne {confirmationToken: new ObjectId(token)}, (err, doc) ->
      throw new Error "Failed to query users" if err?
      console.log doc
      return null unless doc?
      doc.confirmationToken = null
      doc.confirmed = true
      db.collection('users').save(doc)
      callback doc


  create: (user, callback) ->
    #Ensure email is unique
    db.collection('users').find({email: user.email}).count (err, count) ->
      throw err if err?
      return callback {notUnique: true} if count > 0

      user.lastNameInitial = user.lastName.substr 0, 1
      user.password = self.hashPassword user.password
      user.confirmed = false
      user.confirmationToken = new ObjectId()

      db.collection('users').insert user
      bus.emit 'newUser', user

      callback null
