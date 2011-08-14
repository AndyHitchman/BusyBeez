mongoskin = require 'mongoskin'

client = mongoskin.db 'localhost/busybeez'

exports.Db = client
exports.ObjectId = client.db.bson_serializer.ObjectID
