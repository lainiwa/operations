## Case: Data ingestion pipeline

In this section we are seeking high-level answers, use a maximum of couple of paragraphs to answer the questions.

### Extended service

Imagine that for providing data to fuel this service, you need to receive and insert big batches of new prices, ranging within tens of thousands of items, conforming to a similar format. Each batch of items needs to be processed together, either all items go in, or none of them do.

Both the incoming data updates and requests for data can be highly sporadic - there might be large periods without much activity, followed by periods of heavy activity.

High availability is a strict requirement from the customers.

#### How would you design the system?
I will assume that we receive the data from some *stream*,
and we want to batch it for performance reasons.
For that we would need a queue. This could be either a DB like Kafka/Redpanda or we could temporarily place the data to s3 storage (vanilla postgresql would need non-standard extensions added).

#### How would you set up monitoring to identify bottlenecks as the load grows?
There a lot of metrics, but among the very first to be monitored (and alerted upon) should be:
* latency of request-responses
* errors
* space used (especially dead tuples)
* CPU, memory and IO saturation
* RPS and request sizes, connected clients

We could use e.g. Prometheus+Grafana to collecting metrics, storing them and alerting.

#### How can those bottlenecks be addressed in the future?
When we have the metrics, we can tune our DB according to it's load patterns.

Provide a high-level diagram, along with a few paragraphs describing the choices you've made and what factors you need to take into consideration.

Scheme (arrows mean data flow direction):
```
  ┌───────────┐      ┌────────────┐
──┤ETL Process├──┬──►│ Queue      ├──┐
  └───────────┘  │   └────────────┘  │
                 │                   │
  ┌───────────┐  │   ┌────────────┐  ▼   ┌─────────┐
──┤ETL Process├──┼──►│ Queue      ├─────►│Database │
  └───────────┘  │   └────────────┘  ▲   └────┬────┘
                 │                   │        │
  ┌───────────┐  │   ┌────────────┐  │        ▼
──┤ETL Process├──┴──►│ Queue      ├──┘   ┌─────────┐
  └───────────┘      └────────────┘      │Exporter │
                                         └────┬────┘
                                              │
                                              ▼
                        ┌──────────┐     ┌──────────┐
                        │Grafana   │◄────┤Prometheus│
                        └──────────┘     └──────────┘
```

### Additional questions

Here are a few possible scenarios where the system requirements change or the new functionality is required:

1. The batch updates have started to become very large, but the requirements for their processing time are strict.

* Use `COPY` instead of `INSERT`
* Insert data into `UNLOGGED` table
* Our data is timeseries: maybe we can drop old data?
* `price integer` has way too big type: `max(price)` is 5893
* It depends on what we define as "processing time": we might switch to a solution like clickhouse (which is a better fit for timeseries data). The insertion would be rather fast (as the data would be merged in the background)
* Also, the chunking itself takes some time, so the data would not reach DB instantly. If we want to reduce insertion latency, we should aim for smaller chunks.
* We could partition the table (or shard the DB)

2. Code updates need to be pushed out frequently. This needs to be done without the risk of stopping a data update already being processed, nor a data response being lost.

* Postgresql has "smart" shutdown, which waits for all clients to disconnect first
* In our code we should implement similar mechanism of graceful shutdown
* New API processes could be spawned not after other processes are dead, but before that
* I'd implement the retry mechanisms on the clients anyway :)

3. For development and staging purposes, you need to start up a number of scaled-down versions of the system.

This is actually the way I did it: Traefik load-balances 5 prod instances, and 3 stage instances.

Please address *at least* one of the situations. Please describe:

- Which parts of the system are the bottlenecks or problems that might make it incompatible with the new requirements?
- How would you restructure and scale the system to address those?
