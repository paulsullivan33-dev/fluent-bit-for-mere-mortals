# Real jobs

Outcome: the pieces assembled into
working pipelines you could actually
run — the ticket-desk pipeline complete,
and two variations built from parts the
lab already verified.

## Job one: the ticket-desk pipeline, complete

This is chapter 7's configuration
(`fluent-bit-lab/configs/t03-filtered.conf`)
read as a job rather than an exercise:

- **Collect** the application log the
  moment lines land in it (tail, with a
  DB so restarts resume instead of
  repeating).
- **Parse** each JSON line into fields,
  taking the event's own timestamp.
- **Shape**: rename `message` to the
  `event` name downstream expects, and
  stamp the pipeline's name on every
  record.
- **Filter**: drop the DEBUG noise at
  the source, where dropping is cheap.
- **Deliver** to a file: 10 lines in,
  7 records out, every one of them
  fielded, timed, and shaped.

Nothing in it is a placeholder. Swap
the fixture path for a real
application's log, the file output for
your destination (chapter 11), and the
counts discipline — in, kept, dropped —
stays exactly the same.

## Job two: the receiving dock

Chapter 9's HTTP input is the other
half of many real deployments: one
Fluent Bit, centrally placed, accepting
POSTed records from small machines that
run their own Fluent Bits with an
`http` or `forward` output — or from
any program that can POST JSON. The
verified core is the listener on
127.0.0.1:18084 and the record arriving
at its output. In production the same
shape binds a real interface, and the
receiving pipeline parses, routes by
tag, and files per source — chapters 6
and 10, unchanged. (Network exposure
and authentication are deployment
decisions this lab, loopback-only by
design, does not demonstrate.)

## Job three: the split shift

Chapter 10's routing, given a purpose:
one process, two tiers, two files —
web records to one destination, worker
records to another, counts 2 and 3.
The production version of this job is
usually about *retention*: errors kept
for a year, debug kept for a day, each
stream routed to storage priced for its
retention. The mechanism does not
change — tags in, Match patterns out,
counts checked after every change.

## The job that is not here

Notice what none of these jobs does:
search yesterday's logs, graph error
rates, or page anyone. Those jobs
belong to the systems at the river's
mouth (chapter 15). A real deployment
is the pair — Fluent Bit moving
records, and a store behind it keeping
and answering — and judging Fluent Bit
by the second half's questions is how
people talk themselves into the wrong
tool.

Check: take job one and change one
thing — the fixture path, the dropped
level, or the output file — then verify
the new counts match the prediction you
made before running it. A pipeline you
can predict is a pipeline you
understand.
