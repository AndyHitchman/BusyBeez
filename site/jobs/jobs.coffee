require 'date-utils'
_date = require 'underscore.date'
_ = require 'underscore'
{db} = require '../modules/db.coffee'
user = require('../profiles/profiles.coffee').middleware


exports.routes = (app) ->

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
      possibleCompletionDates: __.buildPossibleDates()


  app.post '/jobs/new', (req, res) ->
    input = req.body
    console.log input

    #Validate the input. We're relying on client side JS to help the user. This is a simple guard.
    if !input.type or !input.title or !input.description or !input.maxPayment or
       (input.type != 'online' and
         (input.locations.length == 0 or
          !_(input.locations).some (l) -> l.id))
      throw new Error("invalid input")

    #Save the unconfirmed job into session state and redirect to confirm, possibly via logon or create profile.
    req.session.newJob = input
    res.redirect '/jobs/confirmnew'


  app.get '/jobs/confirmnew',
    user.mustBeSignedIn("We've got that job on hold while you log on or create a profile"),
    (req, res) ->
      newJob = req.session.newJob
      return res.redirect '/jobs/new' if !newJob?

      __.create newJob, (err) ->
        res.render 'jobs/confirmnew'



bus.on 'newJob', (job) ->
  console.log "STUB new job"


__ =
  create: (job, callback) ->
    bus.emit 'newJob', job
    callback()


  buildPossibleDates: ->
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
