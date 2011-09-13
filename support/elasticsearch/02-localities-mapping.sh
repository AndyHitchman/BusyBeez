#!/bin/sh
curl -XPUT 'http://localhost:9200/busybeez/localities/_mapping' -d '
{
  "localities" : {
    "properties" : {
      "postcode" : { "type" : "string", "analyzer" : "keyword" },
      "locality" : { "type" : "string", "analyzer" : "literal" },
      "state" : { "type" : "string", "analyzer" : "keyword" },
      "zone" : { "type" : "string", "analyzer" : "keyword" }
    }
  }
}'