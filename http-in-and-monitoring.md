# HTTP in, and monitoring

Outcome: records pushed into Fluent Bit
over HTTP with `curl` and seen arriving
at a file output — and Fluent Bit's own
monitoring server answering questions
about the pipeline itself.

## The HTTP input

Not every source is a file. The `http`
input listens on a port and accepts
records over HTTP; anything that can
POST JSON can be a source. The lab's
configuration
(`fluent-bit-lab/configs/t06-http-input.conf`)
binds loopback only, on the lab's
assigned port:

```
[SERVICE]
    HTTP_Server  On
    HTTP_Listen  127.0.0.1
    HTTP_Port    19084

[INPUT]
    Name   http
    Listen 127.0.0.1
    Port   18084
    Tag    http.test

[OUTPUT]
    Name   file
    Match  http.test
    Path   ../outputs
    File   t06-http.log
```

The driver
(`fluent-bit-lab/drivers/run-t06-http.sh`,
transcript `t06-http-client.txt`) POSTs
one record from
`fluent-bit-lab/fixtures/http-payload.json`:

```
$ curl -s -i -X POST http://127.0.0.1:18084/ -H 'Content-Type: application/json' --data-binary @http-payload.json
HTTP/1.1 201 Created
server: Fluent Bit
```

`201 Created` is the acknowledgement —
the record was accepted into the
pipeline. And it arrived
(`fluent-bit-lab/outputs/t06-http.log`):

```
http.test: [1794088669.762691924, {"level":"INFO","message":"ticket created over http","service":"ticket-desk","ticket":401}]
```

The tag came from the input's `Tag`
setting, so everything after the POST —
parsing, filtering, routing — treats a
pushed record exactly like a tailed
one. The `http` input also accepts
other shapes and paths; the JSON POST
above is the form the lab verified.

Binding matters: this input was bound
to `127.0.0.1`, so only this machine
could push to it. The HTTP input has no
authentication of its own in the form
shown; on a shared network, an open
ingest port is an open door, and real
deployments put it behind network
controls or a proxy. That is a
documented consideration, stated here
rather than demonstrated.

## The monitoring server

`HTTP_Server On` starts a second,
separate listener — the lab put it on
port 19084 — that answers for Fluent
Bit itself:

```
$ curl -s http://127.0.0.1:19084/api/v1/uptime
{"uptime_sec":5,"uptime_hr":"Fluent Bit has been running:  0 day, 0 hour, 0 minute and 5 seconds"}

$ curl -s http://127.0.0.1:19084/api/v1/metrics
{"input":{"http.0":{"records":0,"bytes":0}},"filter":{},"output":{"file.0":{"proc_records":0,"proc_bytes":0,"errors":0,"retries":0,"retries_failed":0,"dropped_records":0,"retried_records":0}}}
```

The metrics answer is the pipeline's
ledger: records and bytes per input,
and per output the processed counts
plus `errors`, `retries`, and
`dropped_records` — the counters
chapter 12's failures would move. A
Prometheus-format form of the same data
lives at `/api/v1/metrics/prometheus` —
in the same transcript, after the POST,
it reports the input's 92 bytes. One honest gap, found by
asking: on 5.1.5, `GET /api/v1/health`
answers **404** — this version does not
serve that path, and the guide does not
pretend otherwise. `uptime` and
`metrics` are the liveness answers this
version actually gives.

Check: POST the fixture payload, see
`201`, and find the record in the file
output; then read `/api/v1/metrics` and
name which counter would rise if the
output started failing. Both answers
are on the page you just read.
