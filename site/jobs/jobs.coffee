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
      model:
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
    req.session.job = input
    res.redirect '/jobs/confirmnew'


  app.get '/jobs/confirmnew',
    __.sessionHasJob,
    user.mustBeSignedIn("We've got that job on hold while you log on or create a profile"),
    (req, res) ->
      #Suggest tags by searching
      res.render 'jobs/confirmnew'
        model: req.job
        friendlyTicksText: __.friendlyTicksText


  app.post '/jobs/confirmnew',
    __.sessionHasJob,
    user.mustBeSignedIn("We've got that job on hold while you log on or create a profile"),
    (req, res) ->

      res.redirect 'home'


bus.on 'newJob', (job) ->
  console.log "STUB new job"


__ =
  sessionHasJob: (req, res, next) ->
    req.job = req.session.job
    return res.redirect '/jobs/new' if !req.job?
    next()


  create: (job, callback) ->
    bus.emit 'newJob', job
    callback()


  buildPossibleDates: ->
    possibleDates = []
    day = Date.today()

    #If before 9pm then today is OK.
    if new Date().getHours() < 21
      possibleDates.push { value: day.getTime(), text: __.friendlyDateText day }

    #The next two weeks
    _.each _.range(13), ->
      possibleDates.push { value: day.addDays(1).getTime(), text: __.friendlyDateText day }

    possibleDates

  friendlyTicksText: (dateTicks) ->
    dateTicks = Number(dateTicks)
    day = new Date(Number(dateTicks))
    return "Today (#{ _date(day).format 'Do' })" if dateTicks == Date.today().getTime()
    return "Tomorrow (#{ _date(day).format 'Do' })" if dateTicks == Date.tomorrow().getTime()
    return _date(day).format 'dddd Do MMMM'

  friendlyDateText: (day) -> __.friendlyTicksText day.getTime()