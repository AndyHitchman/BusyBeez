_ = require 'underscore'
presence = require '../../modules/presence.coffee'

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
    console.log presence.loggedOnUser
    input = req.body   
    console.log input

    #Validate the input. We're relying on client side JS to help the user. This is a simple guard.
    if !input.type or !input.title or !input.description or !input.privateNotes or
       (input.type != 'online' and
         (input.locations.length == 0 or 
          !_(input.locations).some (l) -> l.id))
      throw new Error('invalid input')

    #Store it
    #Make stuff happen?

    res.send('done')
