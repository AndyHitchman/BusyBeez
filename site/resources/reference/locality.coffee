_ = require 'underscore'
db = require('../../modules/db.coffee').db

module.exports = (app) ->
  app.get '/reference/locality', (req, res) ->
    max = 10
    match = '^' + req.param('term').split('(')[0]
    match += '$' if req.param('exact')

    db.collection('localities')
      .find({locality: { $regex : match, $options: 'i'}})
      .limit(100)
      .toArray (err, items) ->
        res.send
          items: _(items).chain()
                  .first(10)
                  .map((i) -> {
                    id          : i._id
                    label       : i.locality
                    supplement  : {
                      suburb          : i.locality
                      postcode        : i.postcode
                      state           : i.state
                    }
                  })
                  .value(),
          meta:
            clipped:  items.length == 100,
            more:     if items.length > max then true else false,
            excess:   items.length - max,
            matches:  items.length

