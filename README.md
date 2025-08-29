# debezium-ibmi-demo

Quick demo of Debezium with IBM i 

## quick notes

Install process with docker compose + DB2 for i plugin download from Maven Central

## How to test 

Install a Kafka client, and run the samples commands below :
1. Create topic
```
kafka-topics --create --topic test --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
````
2. Produce on topic (publish)
````
kafka-console-producer --broker-list localhost:9092 --topic test     
````
3. List topics
````
kafka-topics --list --bootstrap-server localhost:9092
__consumer_offsets
connect_configs
connect_offsets
connect_statuses
db2i.ACMEAIR.CUSTOMER
test
````
4. Consome on a topic, here on CUSTOMER table: 
````
kafka-console-consumer --bootstrap-server localhost:9092 --topic db2i.ACMEAIR.CUSTOMER --from-beginning
````
Result payload on row update:

    "payload": {
        "ID": "uid0@email.com",
        "PASSWORD": "pass2",
        "STATUS": "password",
        "TOTAL_MILES": 1032696,
        "MILES_YTD": 0,
        "PHONENUMBER": "919-123-4567",
        "PHONENUMBERTYPE": "BUSINESS",
        "STREETADDRESS1": "156 Main Street",
        "STREETADDRESS2": "address-na",
        "CITY": "MontpellierLONGLIVE",
        "STATEPROVINCE": "27617",
        "COUNTRY": "USA",
        "POSTALCODE": "27648"
    }

