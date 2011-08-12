_ = require 'underscore'
db = require('../../modules/db.coffee').db
presence = require('../../modules/presence.coffee').presence

module.exports = (app) ->
  app.get '/jobs', (req, res) ->
    db.collection('jobs').findItems {}, (err, items) ->
      res.render 'jobs',
        jobs: 
          _(items)
            .map (j) ->
              j.avatar = 'fred'
              j
  
  app.get '/jobs/new', (req, res) ->
    res.render 'jobs/new',
      type: null
  
  app.post '/jobs/new', presence.loggedOnUser, (req, res) ->
    console.log req.user?
    input = req.body   
    console.log req.body

    #Validate the input. We're relying on client side JS to help the user. This is a simple guard.
    if !input.type or !input.title or !input.description or 
       (input.type != 'online' and
         (input.locations.length == 0 or 
          !_(input.locations).some (l) -> l.id))
      throw new Error('invalid input')

    #Store it
    #Make stuff happen?

    res.send('done')
