
###
  Module dependencies.
###

require 'less'
express = require 'express'
{helpers, dynamicHelpers} = require './modules/helpers.coffee'
app = module.exports = express.createServer();
{EventEmitter} = require 'events'

# Configuration

app.configure () ->
  app.set 'views', __dirname + '/resources'
  app.set "view engine", 'jade'
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session { secret: "Lady Ada Byron" }
  app.use express.methodOverride()
  app.use express.compiler { src: __dirname + '/public', enable: ['less'] }
  app.use app.router
  app.use express.static __dirname + '/public'

app.configure 'development', () ->
  app.use express.errorHandler { dumpExceptions: true, showStack: true }
  global.domainName = 'localhost:3000'

app.configure 'production', () ->
  app.use express.errorHandler()

app.helpers helpers
app.dynamicHelpers dynamicHelpers


# Entities

global.bus = new EventEmitter
require('./domain/user.coffee')

# Resources

require('./resources/home/home.coffee')(app)
require('./resources/profiles/profiles.coffee').routes(app)
require('./resources/jobs/jobs.coffee').routes(app)
require('./resources/reference/locality.coffee')(app)
require('./resources/reference/fakelogin.coffee')(app)

app.listen 3000
console.log "Express server listening on port #{app.address().port}, in #{app.settings.env} mode"
