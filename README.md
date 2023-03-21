# debezium-postgres-kafka-connector

### commands

- `mvn archetype:generate -DgroupId=com.kinnate -DartifactId=oracle-numb-to-int -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false`
- Add the proper dependencies, which are already added to the `pom.xml` file
- `mvn package`
- copy the `.jar` file to the directory where the Dockerfile is.
- use `kubectl` to apply the (1) cluster connector (2) debezium oracle connector and (3) debezium postgres connector
- check deployment by running:

```
k get kafka -n kafka
k get kctr -n kafka
k logs ${DEBEZIUM_POD_NAME} -n kafka
k describe kctr ${DEBEZIUM_CONNECTOR_NAME} -n kafka
k describe kafkaconnect ${CLUSTER_NAME} -n kafka
```
