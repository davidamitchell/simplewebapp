# simplewebapp


kafka: https://raw.githubusercontent.com/mattf/openshift-kafka/master/README.md
oc run -it --rm kafka-debug --image=mattf/openshift-kafka --command -- bash
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic events --from-beginning
