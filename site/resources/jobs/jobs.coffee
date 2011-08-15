require 'date-utils'
_date = require 'underscore.date'
_ = require 'underscore'
{EventEmitter} = require 'events'
{Db} = require('../../modules/db.coffee')
{Presence} = require('../../modules/presence.coffee')

module.exports = (app) ->
  app.get '/jobs', (req, res) ->
    Db.collection('jobs').findItems {}, (err, items) ->
      res.render 'jobs',
        jobs: 
          _(items)
            .map (j) ->
              j.avatar = 'fred'
              j
  
  app.get '/jobs/new', (req, res) ->
    res.render 'jobs/new',
      type: 'errand'
      timing: 'by'
      possibleCompletionDates: buildPossibleDates()
        
  
  app.post '/jobs/new', Presence.loggedOnUser, (req, res) ->
    input = req.body   
    console.log input

    #Validate the input. We're relying on client side JS to help the user. This is a simple guard.
    if !input.type or !input.title or !input.description or 
       (input.type != 'online' and
         (input.locations.length == 0 or 
          !_(input.locations).some (l) -> l.id))
      throw new Error('invalid input')

    #Store it
    #db.collection('jobs')

    #Make stuff happen?

    res.send('done')

buildPossibleDates = ->
  possibleDates = []
  day = Date.today()

  #If before 9pm then today is OK.
  if new Date().getHours() < 21
    possibleDates.push { value: day.getTime(), text: "Today (#{ _date(day).format 'Do' })" }

  #Tomorrow
  possibleDates.push { value: day.addDays(1).getTime(), text: "Tomorrow (#{ _date(day).format 'Do' })" }

  #The next two weeks
  _.each _.range(12), ->
    possibleDates.push { value: day.addDays(1).getTime(), text: _date(day).format 'dddd Do MMMM' }

  possibleDates

