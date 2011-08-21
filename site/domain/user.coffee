{db, ObjectId} = require "../modules/db.coffee"
crypto = require "crypto"

exports.user =

  mustBeSignedIn : (signInFlash) ->
    (req, res, next) ->
      signedIn req, res, (err) ->
        if err? then next err
        if !req.user?
          #Redirect to create profile
          req.flash "info", signInFlash ? "You must create a profile or be signed in to continue"
          return res.redirect "/profiles/new?returnto=/jobs/confirmnew"

        next()


  signedIn: (req, res, next) ->
    req.user = req.session.user
    next()


  getById: (id) ->
    db.collection("users").findOne {_id: new ObjectId(id)}, (err, doc) ->
      if err?
        throw new Error "Failed to load user " + id
      else
        req.user = doc


  setSignedInUser: (req, user) ->
    req.session.user =
      id: user._id
      firstName: user.firstName
      lastName: user.lastName
      email: user.email


  hashPassword: (plain) ->
    hash = crypto.createHash "sha1"
    hash.update plain + "Charles Babbage"
    hash.digest "base64"


  create: (user, callback) ->
    #Ensure email is unique
    db.collection("users").find({email: user.email}).count (err, count) ->
      if err?
        throw err

      if count > 0
        return callback {notUnique: true}

      user.lastNameInitial = user.lastName.substr 0, 1
      user.password = hashPassword user.password
      user.confirmed = false
      user.confirmationToken = new ObjectId()

      db.collection("users").insert user
      bus.emit "newUser", user

      callback null


bus.on "newUser", (user) ->
  console.log "STUB" +
    " introductory email sent to " + user.email +
    " with confirmation link https://#{global.domainName}/profile/confirm/#{user.confirmationToken}"

