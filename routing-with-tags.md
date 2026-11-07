# Routing with tags

Outcome: two record streams, two
destinations, no mixing — routing built
from nothing but tags and Match
patterns, and proven by the files.

## The whole mechanism

Routing in Fluent Bit is not a separate
feature. It is a consequence of two
facts already met:

- Every record carries the **tag** its
  input gave it.
- Every output declares a **Match**
  pattern and receives only records
  whose tag matches it.

Patterns are exact (`app.web`), wildcard
(`app.*` matches both of this chapter's
tags; `*` matches everything), and a
record that matches several outputs is
delivered to *each* of them — outputs
are subscribers, not a switchboard that
sends a record to one place only.

## Two streams, two files

Configuration
`fluent-bit-lab/configs/t07-routing.conf`
runs two dummy inputs with different
tags and sample counts — 2 for the web
tier, 3 for the worker tier — and two
file outputs, each matched to one tag:

```
[INPUT]
    Name    dummy
    Tag     app.web
    Dummy   {"message":"web request","tier":"web"}
    Rate    1
    Samples 2

[INPUT]
    Name    dummy
    Tag     app.worker
    Dummy   {"message":"background job","tier":"worker"}
    Rate    1
    Samples 3

[OUTPUT]
    Name   file
    Match  app.web
    Path   ../outputs
    File   t07-web.log

[OUTPUT]
    Name   file
    Match  app.worker
    Path   ../outputs
    File   t07-worker.log
```

## The proof

(transcript `t07-routing-counts.txt`,
from the run logged in
`t07-routing.txt`.)

```
== t07-web.log ==
app.web: [1794088442.395286795, {"message":"web request","tier":"web"}]
app.web: [1794088443.395317123, {"message":"web request","tier":"web"}]
count: 2
== t07-worker.log ==
app.worker: [1794088442.395401517, {"message":"background job","tier":"worker"}]
app.worker: [1794088443.395379937, {"message":"background job","tier":"worker"}]
app.worker: [1794088444.395312478, {"message":"background job","tier":"worker"}]
count: 3
```

Exactly 2 web records in the web file,
exactly 3 worker records in the worker
file, and none of either in the other's
file. Both inputs ran inside one Fluent
Bit process at the same time — the
timestamps interleave — so the
separation is the routing's doing, not
the schedule's.

## Where this goes wrong in real life

Two failure shapes follow from the
mechanism, and both are silent:

- **A tag typo.** Tag an input
  `app.wroker` and its records match no
  output. Fluent Bit does not warn that
  a tag has no subscribers; the records
  flow in and vanish (chapter 4's
  zero-count experiment, at scale).
- **An over-broad Match.** Add a third
  output with `Match *` and every
  record gains a second destination —
  sometimes that is the intent
  (a copy to an archive), sometimes it
  is a leak.

Tags can also be rewritten in flight —
inputs can build tags from file paths,
and filters and stream processing can
re-tag records — named here,
documented-only; the fixed tags above
are the verified core. The habit that
keeps routing honest is the one this
chapter used: after any routing change,
count what landed in each destination
and compare with what the inputs made.

Check: reproduce the two files and
their counts (2 and 3). Then add a
third output with `Match app.*` writing
to a third file, and predict its count
before running (5 — every record matches
it). Routing holds no surprises once
you count.
