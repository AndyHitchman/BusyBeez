_ = require 'underscore'
{suggest} = require('../modules/db.coffee')

exports.routes = (app) ->

  app.get '/reference/tags', (req, res) ->
    options =
      collection : 'tags'
      property   : 'tag'
      term       : req.param('term')
      limit      : 100
      max        : 25
      supplement : (i) ->
        count      : i.count

    suggest options, (items) ->
      res.send items
