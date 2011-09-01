mongoskin = require 'mongoskin'
extend = require 'extend'
_ = require 'underscore'

exports.db = db = mongoskin.db 'localhost/busybeez'
exports.ObjectId = db.db.bson_serializer.ObjectID

exports.suggest = (options, callback) ->
  settings =
    max: 10
    limit: 100
    exact: false

  extend(settings, options)

  match = '^' + settings.term
  match += '$' if settings.exact
  find = {}
  find[settings.property] = { $regex : match, $options: 'i' }

  db.collection(settings.collection).find(find).limit(settings.limit)
    .toArray (err, items) ->
      callback
        items:
          _(items).chain()
            .first(settings.max)
            .map((i) -> {
              id          : i._id
              label       : i[settings.property]
              supplement  : settings.supplement?(i)
            })
            .value()
        meta:
          clipped:  items.length == settings.limit,
          more:     if items.length > settings.max then true else false,
          excess:   items.length - settings.max,
          matches:  items.length
