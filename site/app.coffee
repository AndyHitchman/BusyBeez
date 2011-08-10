
###
  Module dependencies.
### 

express = require 'express'
property = require './property.coffee'
mongoskin = require 'mongoskin'
require 'less'

app = module.exports = express.createServer();

# Configuration

app.configure () ->
  app.set 'views', __dirname + '/resources'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.compiler { src: __dirname + '/public', enable: ['less'] }
  app.use app.router
  app.use express.static __dirname + '/public'

app.configure 'development', () ->
  app.use express.errorHandler { dumpExceptions: true, showStack: true } 

app.configure 'production', () -> 
  app.use express.errorHandler() 

app.dynamicHelpers {
    pageTitle: property.create()
  }

db = mongoskin.db 'localhost/busybeez'

# Resources

require('./resources/home/home.coffee')(app, db)
require('./resources/jobs/jobs.coffee')(app, db)
require('./resources/reference/locality.coffee')(app, db)

app.listen 3000
console.log "Express server listening on port #{app.address().port}, in #{app.settings.env} mode"
