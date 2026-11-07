# What Fluent Bit is

By the end of this chapter you can say,
in one sentence, what Fluent Bit takes
off your hands — and state the one rule
that decides whether it helps you or
quietly loses the records you needed.

## The lines nobody collects

Every program writes lines somewhere. A
web service appends to a log file. A
background job prints errors and exits.
A small device keeps a ring of messages
and overwrites the oldest. Those lines
are where the evidence lives when
something later goes wrong — and on
most machines they sit where they were
written, unsearched, unrotated, and
eventually deleted, because collecting
them by hand does not scale past one
machine and one quiet week.

**Fluent Bit** is the collector. It
runs as a small background program on
a machine, reads the lines where they
are written — log files, the system
journal, its own network ports, and
dozens of other sources — gives each
line structure, and **forwards** the
records onward: to a file, to another
machine, to a log service, to a search
system. Its own description, from the
project, is a "fast and lightweight
telemetry agent" for logs, metrics,
and traces. This guide teaches the log
side, which is where most people meet
it.

A pipeline is three steps, and the
whole guide is those three steps made
careful:

```
[INPUT]   tail a file  ->  a stream of records
[FILTER]  parse, shape ->  fields you can use
[OUTPUT]  file, HTTP   ->  somewhere that keeps them
```

## The rule: a river, not a lake

Fluent Bit does not keep your records
for you. It moves them. So:

> **Fluent Bit is a river, not a lake.
> Records flow through it once, shaped
> by the filters they pass, and
> anything you did not parse, tag, or
> route correctly at flow time is not
> waiting for you downstream.**

Each half of that sentence bites in
practice, and this guide's lab measured
both halves:

- **Shaped at flow time, or not at
  all.** A parser that does not match a
  line does not raise an error; the
  line flows on unparsed, with its
  fields still buried inside one raw
  string (chapter 6 shows one, sitting
  in the output next to its parsed
  neighbours). By the time you notice,
  that record has already arrived —
  and left — in the wrong shape.
- **Routed at flow time, or not at
  all.** An output only receives the
  records whose **tag** matches its
  **Match** pattern. A mistyped tag is
  not an error either; the records
  simply go somewhere else, or
  nowhere, while the pipeline looks
  healthy (chapter 10).
- **Kept downstream, or not at all.**
  Fluent Bit's own memory of a record
  lasts as long as delivery takes,
  plus a bounded retry when delivery
  fails (chapter 12 watched a chunk
  retry with growing delays and then
  be dropped, on the record). Long-term
  storage and searching belong to the
  system you forward *to* — chapter 15
  is blunt about the boundary.

The river image also carries the good
news: a river is cheap to run. Fluent
Bit is a single small program written
in C, made to sit on every machine —
including small ones — and move records
without becoming the workload. This
guide's lab ran the official
**Fluent Bit 5.1.5** package, extracted
to a folder rather than installed, and
every pipeline in it ran on loopback,
talking only to itself.

Check: say what the three steps of a
pipeline are, then say the rule out
loud once — river, not lake, shaped at
flow time or not at all. If you can do
both, you have this chapter.
