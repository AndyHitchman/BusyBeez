{db, ObjectId} = require './db.coffee'
crypto = require 'crypto'

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

  setLoggedOnUserId: (req, id) ->
    req.session.userId = id

  hashPassword: (plain) ->
    hash = crypto.createHash 'sha1'
    hash.update plain + 'Charles Babbage'
    hash.digest 'base64'
