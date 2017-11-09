# simplewebapp

export KAFKA_HOST=localhost; export KAFKA_PORT=9092; 
export POSTGRESQL_SERVICE_HOST=localhost; export POSTGRESQL_USER=765440; export POSTGRESQL_DATABASE=frontend_dev

export DB_CONNECTION_STRING="dbname=greenscreen_dev user=765440 sslmode=disable"


kafka-topics  --zookeeper localhost:2181 --list
kafka-topics  --zookeeper localhost:2181 --delete --topic events




kafka: https://raw.githubusercontent.com/mattf/openshift-kafka/master/README.md
oc run -it --rm kafka-debug --image=mattf/openshift-kafka --command -- bash
bin/kafka-console-consumer.sh --bootstrap-server apache-kafka.myproject.svc:9092 --topic events --from-beginning
