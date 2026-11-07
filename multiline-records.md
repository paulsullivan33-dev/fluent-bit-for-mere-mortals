# Multiline records

Outcome: a stack trace — eight lines in
the file — arriving as the single
record it really is, folded by a
multiline parser, plus the exact error
the older switch produces on this
version.

## The problem

Some events refuse to fit on one line.
`fluent-bit-lab/fixtures/stacktrace.log`
holds three events in eight lines:

```
2026-11-07 09:20:01 INFO ticket-desk starting export job 301
2026-11-07 09:20:02 ERROR ticket-desk export job 301 failed
java.lang.IllegalStateException: export buffer full
    at com.example.ticketdesk.ExportJob.run(ExportJob.java:142)
    at com.example.ticketdesk.Worker.main(Worker.java:58)
Caused by: java.io.IOException: disk quota exceeded
    at com.example.ticketdesk.Store.write(Store.java:87)
2026-11-07 09:20:03 INFO ticket-desk export job 302 started
```

Read line by line, the five trace lines
become five orphan records — no
timestamp of their own, no level, and
separated from the ERROR they explain.
Read as events, they are one record.

## The multiline parser

A **multiline parser** is a small state
machine in `parsers.conf`: which lines
start a new record, and which continue
the previous one.

```
[MULTILINE_PARSER]
    Name          stack_multiline
    Type          regex
    Flush_Timeout 1000
    Rule          "start_state"   "/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/"  "cont"
    Rule          "cont"          "/^(?!\d{4}-\d{2}-\d{2})/"               "cont"
```

The first rule: a line starting with a
date begins a record, and moves to the
`cont` state. The second: in `cont`, a
line *not* starting with a date is
appended to the record in progress.
`Flush_Timeout 1000` says a record
waiting more than a second for
continuation lines is sent on — folding
must never hold a record hostage.

The tail input names it
(configuration `t05-multiline.conf`):

```
    Multiline.Parser  stack_multiline
```

## The result

Eight lines in, **three records** out
(transcript `t05-multiline.txt`). The
middle record is the whole event, trace
included, newlines preserved:

```
[1] app.stack: [[1794088368.448908306, {}], {"log"=>"2026-11-07 09:20:02 ERROR ticket-desk export job 301 failed
java.lang.IllegalStateException: export buffer full
    at com.example.ticketdesk.ExportJob.run(ExportJob.java:142)
    at com.example.ticketdesk.Worker.main(Worker.java:58)
Caused by: java.io.IOException: disk quota exceeded
    at com.example.ticketdesk.Store.write(Store.java:87)
"}]
```

Downstream, that record parses, routes,
and alerts as one thing. The trace
stays attached to its ERROR — which,
per chapter 1, had to be arranged here,
at flow time; no downstream system can
reassemble lines it received apart.

## The older switch, on this version

Older configurations use `Multiline
On` with a first-line parser. On
5.1.5, `Multiline On` on its own fails
at startup (configuration
`t05-multiline-oldstyle.conf`,
transcript `t05b-multiline-oldstyle-error.txt`):

```
[error] [input:tail:tail.0] multiline: no parser defined for firstline
[error] failed initialize input tail.0
[error] [engine] input initialization failed
```

Kept in the record on purpose: version
drift is normal in this tool, the error
is precise about what is missing, and
`Multiline.Parser` is the form this
version wants. Fluent Bit also ships
built-in multiline parsers for common
shapes (Docker, CRI, Go, Java, and
others, listed in the tail input's
help) — named here, documented-only;
the lab defined its own so the rules
were visible.

Check: count the fixture's lines (8)
and the output's records (3), and find
the `Caused by:` line inside a record
rather than standing as one. That is
multiline working.
