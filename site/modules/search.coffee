ElasticSearchClient = require 'elasticSearchClient'

serverOptions =
  host: 'localhost'
  port: 9200

exports.elasticSearchClient = client = new ElasticSearchClient(serverOptions)


class IndexSearcher
  constructor: (@indexName) ->

  index: (typeName, document, options) ->
    client.index @indexName, typeName, document, options

  deleteDocument: (typeName, documentId, options) ->
    client.deleteDocument @indexName, typeName, documentId, options

  get: (typeName, queryObj, options) ->
    client.get @indexName, typeName, queryObj, options

  search: (typeName, queryObj, options) ->
    client.search @indexName, typeName, queryObj, options

  percolator: (typeName, queryObj, options) ->
    client.percolator @indexName, typeName, queryObj, options

  percolate: (typeName, doc, options) ->
    client.percolate @indexName, typeName, doc, options

  count: (typeName, query, options) ->
    client.count @indexName, typeName, query, options

  deleteByQuery: (typeName, queryObj, options) ->
    client.deleteByQuery @indexName, typeName, queryObj, options

  moreLikeThis: (typeName, documentId, options) ->
    client.moreLikeThis @indexName, typeName, documentId, options


exports.indexSearcher = (indexName) -> new IndexSearcher(indexName)