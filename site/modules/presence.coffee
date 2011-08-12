exports.loggedOnUser = (req, res, next) ->
  userId = req.session.userId
  console.log req.session
  if userId?
    req.user = { id: userId, name: 'dummy' }
    next()
  else
    next new Error 'Failed to load user ' + req.session.userId

