# openresty-kafka-example

A (likely) rough, working example of how to hook an nginx (OpenResty) reverse proxy up to Kafka and push request/response payloads.

## The Scenario

The scenario that I wanted to prove out was:

* an application server proxied through NGINX
* push request and response payloads to Kafka
* zero changes to application code
* minimal effort in deploying/configuring
* Confluent OSS containers are used for convenience. You should be able to use whichever flavour of Kafka you so choose.

## Test Harness Setup

There are a couple of assumptions made here that qualifies as "Works on My Machine":

* Assuming that you've downloaded and unpacked [Kafka](http://www-us.apache.org/dist/kafka/1.1.0/kafka_2.12-1.1.0.tgz)
* You're using the latest Docker toolkit, including `docker-compose`
* Running `docker-compose up` binds to ports on the host machine. If on a Mac using the latest toolkit, this will likely be `localhost`. YMMV for other operating systems.

### Build the Container

```
docker-compose build
```

### Tweak Your hosts File

Adding the kafka and zookeeper aliases to the Docker containers so that you can use them from apps running on your machine.

```
127.0.0.1       localhost kafka zookeeper
```

## Starting Backend Services

### Start Dependencies

```
docker-compose up
```

### Creating a Topic

```
bin/kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic test
```

### Subscribing to Messages

```
bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic test
```

## Testing Message Flow

Using [HTTPie](https://httpie.org/):

```
http --verify=no https://localhost/ name=test
```

Or curl:

```
curl -d '{"name":"test"}' -X POST -k https://localhost/
```

... or of course, just use a browser and navigate to https://localhost/.

Assuming everything is up, running, and connected, you should see the Tomcat homepage wherever you called it from, and the following in the terminal window running the Kafka `kafka-console-consumer` utility:

```
{"response":"<snipped content>","request":{}}
```

If you used a browser, there will be several of these - you'll also see the output of messages for CSS, images, and so on.

## Useful Reading Material

* [OpenResty Pipeline Directives](https://openresty-reference.readthedocs.io/en/latest/Directives/)
* [Cosockets are not Available Everywhere](https://github.com/openresty/lua-nginx-module#cosockets-not-available-everywhere)
