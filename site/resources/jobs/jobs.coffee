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
      job: 
        type: 'online'
  
  #app.post '/jobs/new', (req, res) ->
    
