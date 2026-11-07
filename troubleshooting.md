# Troubleshooting

Outcome: the failures this lab actually
met — each with its exact message, its
cause, and its fix — plus the checks
that find the silent ones.

## It will not start: a plugin name that does not exist

Configuration `t09-broken.conf` names an
output that does not exist. Fluent Bit
refuses to start (transcript
`t09-broken-config.txt`):

```
[error] [config] section 'no_such_output' tried to instance a plugin name that doesn't exist
[error] configuration file contains errors, aborting.
```

Exit code 1, nothing collected. Catch
this class of error before deploying
with a dry run — the same broken file
fails it, and a good one passes:

```
$ fluent-bit --dry-run -c t01-dummy.conf
configuration test is successful
```

(transcripts `t09b-dry-run.txt` and
`t09c-dry-run-broken.txt`).

## It will not start: a property in the wrong place

Putting `storage.type filesystem` on
the `http` output (transcript
`t09d-storage-on-output-error.txt`):

```
[error] [config] http: unknown configuration property 'storage.type'. The following properties are allowed: ...
[ help] try the command: fluent-bit -o http -h
[error] [engine] output initialization failed
```

Two gifts in one message: the list of
properties that *are* allowed, and the
exact command that documents the
plugin. The fix was a move, not a
rewrite: `storage.type` belongs on the
input (chapter 12). The parser filter
taught the same lesson earlier in the
build — an unsupported
`Skip_Empty_Values` property was named
plainly in its error before the lab
removed it.

## It will not start: the old multiline switch

```
[error] [input:tail:tail.0] multiline: no parser defined for firstline
```

Chapter 8: `Multiline On` without a
first-line parser, on 5.1.5. The
current form is `Multiline.Parser
<name>`.

## It runs, and nothing arrives

Work the river in order; every cause
below was reproduced in this lab:

1. **The tail started at the end.**
   The file existed before Fluent Bit
   started and `Read_From_Head` is not
   set (chapter 5). Symptom: new lines
   arrive, old ones never do.
2. **The tag matches no output.**
   Symptom: input counters in
   `/api/v1/metrics` rise, output
   counters do not (chapter 9). Chapter
   4 manufactures this in one edit.
3. **A filter dropped them.** Count
   before the filters (chapter 7's
   discipline). A `Grep` written
   backwards, or run before the parser,
   drops everything, quietly.
4. **They arrived unparsed and your
   search cannot see them.** They are
   in the output with a single `log`
   field (chapter 6). The pipeline is
   healthy; the shape is not.

## The destination is down

Read the retry log before restarting
anything (chapter 12): "failed to flush
chunk … retry in N seconds" means the
bridge is holding; "cannot be retried"
means those records are gone and the
question becomes how long the outage
outlasted your `Retry_Limit`. The
monitoring counters — `retries`,
`retries_failed`, `dropped_records` —
carry the same story in numbers.

## Doubling after a restart

A tail that re-reads lines it already
sent usually has no DB file, or a DB
pointing somewhere new. The DB is the
pipeline's memory of position
(chapter 5); treat it like state,
because it is.

Check: break a copy of a working
configuration in each of the three
startup ways above and read each error
aloud — all three name their own cause.
Then manufacture silence (a wrong
Match) and find it with the metrics
counters. Troubleshooting this tool is
mostly reading what it already told
you.
