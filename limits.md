# Limits

Outcome: the honest boundary of the
tool, stated before it costs you —
what Fluent Bit does not do, what it
does silently, and where its buffers
end.

## It forwards and shapes. It does not store or answer

Fluent Bit is not a database. It keeps
no searchable history, answers no
queries, and builds no dashboards.
Records that have been delivered are
the destination's to keep; records that
could not be delivered are kept only
until the retry limit says otherwise
(chapter 12). Any question of the form
"show me last Tuesday's errors" is
addressed to the system at the river's
mouth, not to the river.

## It is not a metrics database, and not an alerting tool

Fluent Bit can collect and forward
metrics and can count things as they
pass, but it is not a time-series store
and it does not watch thresholds and
page people. Its own monitoring
counters (chapter 9) describe the
pipeline, not your service. Alerting
belongs downstream, where the kept
records are.

## A parser that does not match fails silently

Chapter 6's fifth record is the whole
point: no error, no warning at the
default log level — the line flows on
unparsed, fields buried in one raw
string, arrival time standing in for
event time. Every downstream consumer
sees a record that looks merely empty.
Formats drift in real systems; a parser
written for last year's log line meets
this year's, and the failure mode is
absence, not noise. Count parsed
against unparsed yourself, or accept
that you will find out late.

## Backpressure is real, and its buffers have ends

- Memory buffering is fast and
  volatile: a dead process takes its
  waiting chunks with it.
- Filesystem buffering survives
  restarts and can fill a disk; the
  service caps waiting chunks
  (`max_chunks_up` — 128 in the lab)
  and inputs can be capped with
  `Mem_Buf_Limit`, at which point the
  input pauses: a fast source and a
  slow destination meet, and something
  has to give.
- Retries end. `Retry_Limit` is a
  number, the backoff schedule is
  finite, and past the end the chunk is
  dropped with a log line as its only
  obituary (chapter 12).

None of these limits is a defect. They
are what "lightweight forwarder" means,
priced honestly. The defect would be
deploying it as if they were not there.

## Silent is its favourite failure mode

Routing mismatches (chapter 4's zero
records), unmatched parses, dropped
DEBUG lines — Fluent Bit's defaults
favour flowing over complaining. That
is right for a program that must never
take down the machine it watches, and
it puts the burden of verification on
you: counts in and out, per destination,
checked after every configuration
change. The chapters of this guide
counted everything for exactly this
reason.

## Small print the lab noticed

- Tail starts existing files at their
  end unless told otherwise (chapter
  5) — a "missing history" report is
  usually this default, not a failure.
- `/api/v1/health` does not exist on
  5.1.5 (chapter 9); liveness checks
  written for it will 404.
- Plugin properties change between
  versions, and wrong ones are startup
  errors with good messages (chapter
  16) — expect to adjust old
  configurations, not just copy them.

Check: state the four big limits from
memory — no storage or query, no
metrics store or alerting, silent
parse failure, finite buffering — and
name the chapter that demonstrated the
one that surprised you most.
