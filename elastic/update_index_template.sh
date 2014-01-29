curl -XPUT http://localhost:9200/_template/logstash_per_index -d '
{
    "template": "logstash-*",
    "settings": {
        "analysis": {
            "analyzer": {
                "my_analizer": {
                    "type": "custom",
                    "tokenizer": "my_pattern_tokenizer",
                    "filter": [
                        
                    ]
                }
            },
            "tokenizer": {
                "my_pattern_tokenizer": {
                    "type": "pattern",
                    "pattern": "$^"
                }
            },
            "filter": [
                
            ]
        }
    },
    "mappings": {
      "_default_" : {
        "properties" : {
          "@fields" : { 
            "properties" : {
                "title" : {
                  "type": "string",
                  "store": "yes",
                  "analyzer": "my_analizer",
                  "search_analyzer": "my_analizer"
                }
            }
          }
        }
      }
    }
}
'
