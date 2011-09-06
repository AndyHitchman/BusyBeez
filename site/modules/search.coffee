ElasticSearchClient = require 'elasticSearchClient'

serverOptions =
  host: 'localhost'
  port: 9200

exports.search = new ElasticSearchClient(serverOptions)
