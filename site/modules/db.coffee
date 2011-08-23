mongoskin = require 'mongoskin'

client = mongoskin.db 'localhost/busybeez'

exports.db = client
exports.ObjectId = client.db.bson_serializer.ObjectID
