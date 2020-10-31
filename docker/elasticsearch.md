- [[Elastic Search]]: [[DevOps]]
    - Deploy to [[Dokku]]:
        - Export image version: `export ELASTICSEARCH_IMAGE_VERSION="7.6.2"`
        - Export image registry: `export ELASTICSEARCH_IMAGE="docker.elastic.co/elasticsearch/elasticsearch"`
        - Edit ` (/var/lib/dokku/services/elasticsearch/myindex/config/elasticsearch.yml` content:
```clojure
node.name: node-1
cluster.name: docker-cluster
network.host: 0.0.0.0
cluster.initial_master_nodes:
  - node-1```
