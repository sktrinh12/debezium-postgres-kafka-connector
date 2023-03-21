./bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --from-beginning --topic orcl_dm.DS3_USERDATA.DISK_SPACE

./kafka-console-consumer.sh --bootstrap-server kafka-cluster-kafka-bootstrap:9092 --topic orcl_dm.DS3_USERDATA.DISK_SPACE --from-beginning

k run -n kafka -it --rm --image=quay.io/debezium/tooling:1.2 --restart=Never watcher -- kcat -b kafka-cluster-kafka-bootstrap:9092 -C -L

k run -n kafka -it --rm --image=quay.io/debezium/tooling:1.2 --restart=Never watcher -- kcat -b kafka-cluster-kafka-bootstrap:9092 -C -o beginning -t orcl_dm.DS3_USERDATA.DISK_SPACE

curl -s "http://localhost:8083/connectors?expand=info&expand=status" |
	jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' |
	column -s : -t | sed 's/\"//g' | sort

docker exec -it debezium_kafka_1 bash
