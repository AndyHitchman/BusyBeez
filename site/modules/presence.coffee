db = require('./db.coffee').db
ObjectId = require('./db.coffee').ObjectId

exports.presence =
  loggedOnUser: (req, res, next) ->
    userId = req.session.userId
    if userId?
      db.collection('users').findOne {_id: new ObjectId(userId)}, (err, doc) -> 
        if err? 
          next new Error 'Failed to load user ' + req.session.userId
        else
          req.user = doc
          next()
    else
      next()
