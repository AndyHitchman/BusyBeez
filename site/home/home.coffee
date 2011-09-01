exports.routes = (app) ->

  app.get '/', (req, res) ->
    res.render 'home'

  app.get '/faq', (req, res) ->
    res.render 'home/faq'
