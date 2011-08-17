require 'date-utils'
_date = require 'underscore.date'
_ = require 'underscore'
{EventEmitter} = require 'events'
{db} = require '../../modules/db.coffee'
{presence} = require '../../modules/presence.coffee'

module.exports = (app) ->
  app.get '/profiles/new', presence.loggedOnUser, (req, res) ->
    returnto = req.param('returnto') ? 'home'
    if req.user? then return res.redirect returnto

    res.render 'profiles/new',
      returnto: returnto
      model: {}


  app.post '/profiles/new', (req, res) ->
    input = req.body   
    returnto = req.param('returnto') ? 'home'

    #Validate the input. We're relying on client side JS to help the user. This is a simple guard.
    if !input.firstName or !input.lastName or !input.suburbId or !input.email or 
       !input.password or !input.confirmPassword
      return res.render 'profiles/new',
        returnto: returnto
        model: input
      
    #Ensure email is unique
    db.collection('users').find({email: input.email}).count (err, count) ->
      if count > 0
        req.flash 'error', 
          'We already have a profile with this email address. Is it yours? Try signing on or request a password reset'
        return res.render 'profiles/new',
          returnto: returnto
          model: input
      else
        user =
          firstName:  input.firstName
          lastName:   input.lastName
          suburb:     input.suburb
          suburbId:   input.suburbId
          email:      input.email
          password:   presence.hashPassword input.password

        db.collection('users').insert user
        presence.setLoggedOnUserId req, user._id
        req.flash 'info',
          "Thanks! We've logged you on and you're good to go! Please look for the confirmation email in your inbox."

        return res.redirect returnto

