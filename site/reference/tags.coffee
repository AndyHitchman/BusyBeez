_ = require 'underscore'
{suggest} = require('../modules/db.coffee')

exports.routes = (app) ->

  app.get '/reference/tags', (req, res) ->
    options =
      collection : 'tags'
      property   : 'tag'
      term       : req.param('term')
      exact      : req.param('exact')
      sort       : { count: -1 }
      supplement : (i) ->
        count : i.count

    suggest options, (items) ->
      res.send items
