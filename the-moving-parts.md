# The moving parts

Outcome: a map of the parts inside
every pipeline, so that when a later
chapter names a behaviour — an unparsed
line, a dropped record, a chunk waiting
to retry — you know which part produced
it and which setting steers it.

## Inputs

An **input** is where records are born.
Each input plugin watches one kind of
source: `tail` follows files, `http`
listens on a network port, `systemd`
reads the journal, `dummy` invents
records for testing. The lab's
`fluent-bit --help` capture lists
forty-odd inputs (transcript
`fluent-bit-lab/transcripts/t00-help-full.txt`).
Every record an input makes carries a
**tag** — a short label you choose,
like `app.json` — and a timestamp.
Almost everything downstream is decided
by that tag.

## Parsers

A **parser** turns one raw string into
named **fields**. A JSON parser reads
`{"level":"ERROR","ticket":103}` and
produces the fields `level` and
`ticket`; a regular-expression parser
pulls the same fields out of a plain
text line by pattern. Parsers live in
their own file (the lab's is
`fluent-bit-lab/configs/parsers.conf`)
and are applied in two places: inside
some inputs, and by the `parser`
**filter**. A parser is a pattern with
opinions; chapter 6 shows what happens
— quietly — when a line does not fit.

## Filters

A **filter** sees every record that
passes its Match pattern and may change
it or drop it. The lab ran three:

- `parser` — apply a parser to a field
  of the record (chapter 6).
- `modify` — add, remove, or rename
  fields (chapter 7 added a `pipeline`
  field and renamed `message` to
  `event`).
- `grep` — keep records that match a
  condition, or **Exclude** ones that
  do; chapter 7 used it to drop every
  `DEBUG` record.

Filters run in the order the
configuration lists them, which is why
the parser goes first: `grep` can only
test `$level` after the parser has
extracted a field named `level`.

## Outputs and Match

An **output** delivers records
somewhere: the `file` and `stdout`
outputs of the early chapters, the
`http` output of chapter 12, and a long
list of services beyond. An output only
receives a record when the record's tag
matches the output's **Match** pattern
— `app.json`, `app.*`, or `*` for
everything. Routing is nothing more
than tags plus Match patterns, and
chapter 10 builds a two-destination
split out of them.

## Chunks, storage, and the scheduler

Inside, records travel in **chunks** —
batches that an output tries to deliver
(a **flush**) every `Flush` seconds.
A chunk that cannot be delivered is
retried by the scheduler with growing
delays, up to the output's
`Retry_Limit`; then it is dropped and
the log says so (chapter 12). Chunks
live in memory by default, or on disk
when an input sets `storage.type
filesystem` and the service sets a
`Storage.Path` — the difference between
"survives a busy minute" and "survives
a restart", and also between two kinds
of full: a full memory buffer pauses
or drops, a full disk is a disk
problem. Chapter 12 lists both chunk
files and the retry log, side by side.

## The service itself

Around the pipeline sits the service:
the log level and its own log lines
(the bracketed `[ info]` / `[ warn]` /
`[error]` messages quoted throughout
this guide), a small built-in HTTP
monitoring server (chapter 9), and the
configuration file itself — classic
format, the `[SECTION]` style this
guide teaches first, or the YAML
format chapter 4 verifies on the same
version.

Check: name the parts in flow order —
input, parser, filters, output — and
say which two settings decide where a
record goes (its tag, and each output's
Match). If you can, the rest of the
guide has somewhere to hang.
