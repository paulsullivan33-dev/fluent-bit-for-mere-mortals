# Fluent Bit for Mere Mortals

Every program you run writes lines
somewhere — an application log, a
journal, a text file on a small machine
nobody visits. Those lines are the
evidence when something goes wrong
later, and on most machines they sit
where they were written until rotation
or a full disk erases them, because
collecting them by hand does not scale.
**Fluent Bit** takes the collecting
over: it reads the lines where they are
written, gives them structure as they
pass, and **forwards** them to the
place that keeps them.

One rule governs everything it does,
and this guide states it in chapter 1
and keeps pointing back to it: **Fluent
Bit is a river, not a lake. Records
flow through it once, shaped by the
filters they pass, and anything you did
not parse, tag, or route correctly at
flow time is not waiting for you
downstream.** A parser that does not
match does not complain — the line
flows on unparsed, and this guide's lab
photographed one doing it. A tag that
matches no output is not an error — the
records simply go nowhere. And a
delivery that keeps failing is retried
for a while — the lab watched the
delays grow, 7 seconds, 15, 32 — and
then the records are dropped, on the
record, in the log. What the river
carries, it carries once.

The lab behind this guide ran the real
thing: **Fluent Bit 5.1.5**, the
official Ubuntu package from the
project's own repository, extracted to
a folder rather than installed, against
a fictional ticket-desk application's
logs. Against that fixture the lab
counted a dummy pipeline's five records
in and out, and ran the same pipeline
in the YAML configuration format;
tailed ten JSON log lines and parsed
them into fields with their own
timestamps; reshaped them with a modify
filter and dropped the DEBUG records
with grep — ten in, seven out; parsed
plain-text lines with a regular
expression and caught the one line that
matched nothing, passing through
unparsed and silent; folded an
eight-line stack trace into three
records with a multiline parser; pushed
a record in over HTTP on loopback and
watched it land in a file, then read
Fluent Bit's own monitoring counters —
including one endpoint this version
does not have; split two tagged streams
into two files with no mixing; pointed
an output at a dead port and recorded
the retries, the growing delays, and
the moment the chunks were dropped; and
listed the chunk files filesystem
buffering wrote to disk while the
outage lasted.

What the lab could not do, it did not
fake. The long list of service outputs
— search systems, object storage,
queues — is characterised, not tested
against live services; hot reload,
stream processing, and the built-in
multiline parsers are named where they
belong and left to the manual.
`criteria.md` keeps the full ledger of
what was run and what was only read.

## What this guide covers

- [**What Fluent Bit is**](what-fluent-bit-is.md) —
  the lines nobody collects, the
  three-step pipeline, and the one rule
- [**The moving parts**](the-moving-parts.md) —
  inputs, parsers, filters, outputs,
  chunks, and the scheduler
- [**Installing Fluent Bit**](installing-fluent-bit.md) —
  the official package the lab used, the
  ordinary install routes, and the
  version check
- [**Your first pipeline**](your-first-pipeline.md) —
  dummy records to the screen, counted,
  in the classic and YAML formats
- [**Reading real logs**](reading-real-logs.md) —
  the tail input, its position database,
  and where a tail starts reading
- [**Parsers**](parsers.md) — JSON and
  regular-expression parsers, event
  time, and the line that matches
  nothing
- [**Filtering and shaping**](filtering-and-shaping.md) —
  modify and grep, in order, with the
  counts before and after
- [**Multiline records**](multiline-records.md) —
  folding a stack trace into one
  record, and the old switch's error
- [**HTTP in and monitoring**](http-in-and-monitoring.md) —
  records pushed in with curl, and the
  monitoring server's answers
- [**Routing with tags**](routing-with-tags.md) —
  two tags, two files, proven by
  counting
- [**Outputs in the large**](outputs-in-the-large.md) —
  the outputs this guide ran, and how
  to judge the rest of the list
- [**Buffering and retries**](buffering-and-retries.md) —
  the dead endpoint, the growing
  delays, the dropped chunks, and the
  chunk files on disk
- [**Real jobs**](real-jobs.md) — the
  ticket-desk pipeline complete, the
  receiving dock, and the split shift
- [**The neighbours**](the-neighbours.md) —
  Fluentd, Logstash, Vector, Filebeat,
  the syslog elders, and the
  OpenTelemetry Collector
- [**Limits**](limits.md) — no storage,
  no queries, no alerting, silent parse
  failures, finite buffers
- [**Troubleshooting**](troubleshooting.md) —
  the exact startup errors, and finding
  the silent failures with counters
- [**Glossary**](glossary.md) — the
  terms, collected in one place

## What it doesn't cover

The systems at the river's mouth —
log stores, search, dashboards, and
alerting — beyond naming them as the
destination's job. Running Fluent Bit
inside containers and orchestrators,
and its metrics and traces pipelines,
are pointed to in the manual; this
guide's pipelines are logs, on one
machine, on loopback. Nothing here
collects anyone else's logs: every
example reads the reader's own files.

## How to use this guide

Read chapter 1 for the rule and
chapter 2 for the map of parts;
chapter 4 gets a pipeline running, and
chapters 5 to 8 teach you to read what
it does to records. Chapter 12 is the
one to read before trusting a pipeline
with an outage: buffering is a bridge,
not a warehouse, and it is cheaper to
learn the retry arithmetic in the lab
than during the incident. The lab's
fixtures live in
`fluent-bit-lab/fixtures/`, its
configurations in
`fluent-bit-lab/configs/`, its driver
scripts in `fluent-bit-lab/drivers/`,
its outputs in `fluent-bit-lab/outputs/`,
and every claim's evidence in
`fluent-bit-lab/transcripts/`; its
distilled commands are
`examples/commands.txt` and its notes
`examples/lab-notes.txt`.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [Text Processing for Mere Mortals](https://paulsullivan33-dev.github.io/text-processing-for-mere-mortals/)
- [Watching Your System for Mere Mortals](https://paulsullivan33-dev.github.io/watching-your-system-for-mere-mortals/)
- [Markdown for Mere Mortals](https://paulsullivan33-dev.github.io/markdown-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/fluent-bit-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/fluent-bit-for-mere-mortals/blob/main/LICENSE-CODE).
