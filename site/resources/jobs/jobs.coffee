require 'date-utils'
_date = require 'underscore.date'
_ = require 'underscore'
{EventEmitter} = require 'events'
{db} = require('../../modules/db.coffee')
{presence} = require('../../modules/presence.coffee')

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
      type: 'errand'
      timing: 'by'
      possibleCompletionDates: buildPossibleDates()
        

  app.post '/jobs/new', (req, res) ->
    input = req.body   
    console.log input

    #Validate the input. We're relying on client side JS to help the user. This is a simple guard.
    if !input.type or !input.title or !input.description or !input.maxPayment or
       (input.type != 'online' and
         (input.locations.length == 0 or 
          !_(input.locations).some (l) -> l.id))
      throw new Error('invalid input')

    #Save the unconfirmed job into session state and redirect to confirm, possibly via logon or create profile.
    req.session.newJob = input
    res.redirect '/jobs/confirmnew'


  app.get '/jobs/confirmnew', presence.loggedOnUser, (req, res) ->
    if !req.user?
      #Redirect to create profile
      req.flash 'info', "We've got that job on hold while you log on or create a profile"
      return res.redirect '/profiles/new?returnto=/jobs/confirmnew'

    res.send 'done'

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

