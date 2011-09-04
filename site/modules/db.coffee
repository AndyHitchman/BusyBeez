mongoskin = require 'mongoskin'
extend = require 'extend'
_ = require 'underscore'

exports.db = db = mongoskin.db 'localhost/busybeez'
exports.ObjectId = db.db.bson_serializer.ObjectID

exports.suggest = (options, callback) ->
  settings =
    max: 20
    limit: 100
    exact: false

  extend(settings, options)

  match = '^' + settings.term
  match += '$' if settings.exact
  find = {}
  find[settings.property] = { $regex : match, $options: 'i' }
  sort = {}
  if settings.sort
    sort = settings.sort
  else
    sort[settings.property] = 1

  db.collection(settings.collection).find(find).sort(sort).limit(settings.limit)
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


exports.complete = (options, callback) ->
  console.log 'Complete ' + options.term
  settings =
    limit: 100

  extend(settings, options)

  match = '^' + settings.term
  find = {}
  find[settings.property] = { $regex : match, $options: 'i' }

  db.collection(settings.collection).find(find).limit(settings.limit)
    .toArray (err, items) ->
      callback(
        _(items)
          .map((i) -> {
            id          : i._id
            label       : i[settings.property]
          })
      )
