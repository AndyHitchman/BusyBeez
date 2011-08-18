{db, ObjectId} = require './db.coffee'
crypto = require 'crypto'

exports.presence = presence =
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


bus.on 'newUser', (user, callback) ->
  #Ensure email is unique
  db.collection('users').find({email: user.email}).count (err, count) ->
    if err?
      throw err

    if count > 0
      return callback {notUnique: true}

    user.lastNameInitial = user.lastName.substr 0, 1
    user.password = presence.hashPassword user.password
    user.confirmed = false
    user.confirmationToken = new ObjectId()

    db.collection('users').insert user

    console.log 'STUB' +
      ' introductory email sent to ' + user.email + 
      ' with confirmation link https://' + global.domainName + '/profile/confirm/' + user.confirmationToken

    callback null, user

bus.on 'newJob', (job, user) ->
