{suggest} = require('../modules/db.coffee')

exports.routes = (app) ->

  app.get '/reference/locality', (req, res) ->
    options =
      collection : 'localities'
      property   : 'locality'
      term       : req.param('term')
      exact      : req.param('exact')
      supplement : (i) ->
        suburb     : i.locality
        postcode   : i.postcode
        state      : i.state

    suggest options, (items) ->
      res.send items


