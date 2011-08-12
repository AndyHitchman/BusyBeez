
###
  Module dependencies.
### 

require 'less'
express = require 'express'
property = require './modules/property.coffee'
app = module.exports = express.createServer();

# Configuration

app.configure () ->
  app.set 'views', __dirname + '/resources'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session { secret: "Lady Ada Byron" }
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


# Resources

require('./resources/home/home.coffee')(app)
require('./resources/jobs/jobs.coffee')(app)
require('./resources/reference/locality.coffee')(app)
require('./resources/reference/fakelogin.coffee')(app)

app.listen 3000
console.log "Express server listening on port #{app.address().port}, in #{app.settings.env} mode"
