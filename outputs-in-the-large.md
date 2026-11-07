# Outputs in the large

Outcome: a clear picture of what an
output is, which outputs this guide ran
for real, and how to judge the long
list of the rest — because the river
has to empty somewhere, and the choice
of somewhere is a design decision.

## What an output promises

An output takes a chunk of records,
translates it into its destination's
shape, and delivers it — or reports
failure so the scheduler can retry
(chapter 12). Outputs differ in three
ways that matter:

- **Destination.** A file on this
  machine, a service on the network, a
  queue, a search system.
- **Format.** The `file` output's plain
  lines in this guide; the `http`
  output's JSON lines; a destination's
  own bulk format elsewhere.
- **Failure behaviour.** What the
  destination's errors look like, and
  whether a failure is retryable —
  chapter 12's dead endpoint is the
  worked example.

## Ran in this guide

- **stdout** — records to the screen
  (chapters 4 and 6). A teaching and
  debugging output, not a destination:
  the screen keeps nothing.
- **file** — records appended to files
  under a `Path`, one `File` per output
  (chapters 5, 7, 9, 10). Simple,
  durable, and the output whose contents
  a reader can inspect with `cat` and
  `wc` — which is why this guide proves
  things with it.
- **http** — records POSTed onward
  (chapter 12, to an endpoint that was
  deliberately not there). Against a
  real receiver this is the generic
  escape hatch: Fluent Bit speaks JSON
  lines, JSON arrays, and other shapes
  via its `Format` setting.

## The long list, characterised

`fluent-bit --help` lists far more
outputs than this guide ran — among
them destinations for search systems,
object storage, queues, metrics
systems, and other log services, plus
`forward` (to another Fluent Bit or
Fluentd) and `null` (deliberately
nowhere — the honest way to discard a
stream you have decided not to keep).
These are **documented-only** here:
named so you know they exist, not
described as if the lab had stood up
each service to test them.

Choosing among them is mostly asking
three questions, in order:

1. Where must these records be
   *queryable* later? That system is
   the destination, or the thing the
   destination feeds — remember the
   river ends at someone else's lake.
2. What does failure look like there,
   and how long can this machine buffer
   while it lasts (chapter 12)?
3. What format does it expect, and
   does a dedicated output exist? A
   dedicated output almost always beats
   bending `http` to imitate one.

Check: name the three outputs this
guide ran and what each was used to
prove; then name the destination you
would choose for a real service's logs
and say which of the three questions
decided it. If you can do both, you can
read the output list without drowning
in it.
