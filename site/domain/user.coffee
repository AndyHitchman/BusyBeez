{db, ObjectId} = require '../modules/db.coffee'
crypto = require 'crypto'
querystring = require 'querystring'

exports.user = self =

  # Route middleware provided the signed in user in req.user, or if not signed in
  # redirects to the sign-in route.
  mustBeSignedIn : (signInFlash) ->
    (req, res, next) ->
      self.signedIn req, res, (err) ->
        next err if err?
        if !req.user?
          #Redirect to create profile
          req.flash 'info', signInFlash ? "You must create a profile or be signed in to continue"
          return res.redirect '/profiles/new?returnto=#{querystring.escape(req.url)}'

        next()


  # Route middleware provides the signed in user in req.user
  signedIn: (req, res, next) ->
    req.user = req.session.user
    next()


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


  confirmUserIdentity: (token) ->
    db.collection('users').findOne {confirmationToken: new ObjectId(token)}, (err, doc) ->
      throw new Error "Failed to query users" if err?
      console.log doc
      return null unless doc?
      doc.confirmationToken = null
      doc.confirmed = true
      db.collection('users').save(doc)
      doc


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


bus.on 'newUser', (user) ->
  console.log 'STUB' +
    " introductory email sent to " + user.email +
    " with confirmation link https://#{global.domainName}/profiles/confirm/#{user.confirmationToken}"

