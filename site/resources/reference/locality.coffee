_ = require 'underscore'

module.exports = (app, db) ->
  app.get '/reference/locality', (req, res) ->
    max = 10
    match = '^' + req.param 'term'

    db.collection('localities')
      .find({locality: { $regex : match, $options: 'i'}})
      .limit(100)
      .toArray (err, items) ->
        res.send _(items)
          .chain()
          .first(10)
          .map((i) ->
            id : i._id, label : i.locality + ' (' + i.state + ')'
          )
          .value()
          .concat(
            if items.length > max
              [{ more: true, excess: items.length - max, clipped: items.length == 100 }]
            else
              []
          )
