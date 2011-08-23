{db} = require '../../modules/db.coffee'
{user} = require '../../domain/user.coffee'
querystring = require 'querystring'

module.exports = (app) ->

  app.get '/profiles/new', user.signedIn, (req, res) ->
    returnto = querystring.unescape(req.param('returnto')) ? 'home'
    if req.user? then return res.redirect returnto

    res.render 'profiles/new',
      returnto: returnto
      model: {}


  app.post '/profiles/new', (req, res) ->
    input = req.body
    returnto = querystring.unescape(req.param('returnto')) ? 'home'

    #Validate the input. We"re relying on client side JS to help the user. This is a simple guard.
    if !input.firstName or !input.lastName or !input.suburbId or !input.email or
       !input.password or !input.confirmPassword
      req.flash 'error', "There's something wrong with the information you entered. Please check and try again"
      return res.render '/profiles/new',
        returnto: returnto
        model: input

    newUser =
      firstName:  input.firstName
      lastName:   input.lastName
      suburb:     input.suburb
      suburbId:   input.suburbId
      email:      input.email
      password:   input.password

    user.create newUser, (err) ->
      if err?.notUnique
        req.flash 'error',
          "We already have a profile with this email address. Is it yours? Try signing in or request a password reset."
        return res.render 'profiles/new',
          returnto: returnto
          model: input

      user.setSignedInUser req, newUser

      req.flash 'info',
        "Thanks #{newUser.firstName}! " +
        "We've logged you on and you're good to go! Please look for the confirmation email in your inbox."
      res.redirect returnto


  app.get '/profiles/confirm/:token', (req, res) ->
    confirmedUser = user.confirmUserIdentity req.params.token
    if confirmedUser?
      user.setSignedInUser req, confirmedUser
      req.flash 'info', "Thanks #{newUser.firstName}! You've activated your profile."
      bun.emit 'profileActivated', confirmedUser
    return res.redirect 'home'
