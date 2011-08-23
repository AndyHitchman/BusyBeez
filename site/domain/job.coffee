{db, ObjectId} = require '../modules/db.coffee'

exports.job = self =
  create: (job, callback) ->
    bus.emit 'newJob', newJob

bus.on 'newJob', (job) ->
  console.log "STUB new job"