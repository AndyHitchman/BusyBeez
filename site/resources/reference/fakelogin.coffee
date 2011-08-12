module.exports = (app) ->
  app.get '/reference/fakelogin/:userId', (req, res) ->
    req.session.userId = req.params.userId
    res.send "Fake login as #{req.params.userId}"
