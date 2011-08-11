_ = require 'underscore'

module.exports = (app, db) ->
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
  
  app.post '/jobs/new', (req, res, next) ->
    input = req.body   
    console.log input
    #Validate the input. We're relying on client side JS to help the user. This is a simple guard.
    if !input.type or !input.title or !input.description or
       (input.type != 'online' and input.locations.length == 0)
      next new Error('invalid input')

    #Store it
    #Make stuff happen?

    res.send('done')
