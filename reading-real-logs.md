# Reading real logs

Outcome: Fluent Bit following a real
file — a fictional ticket-desk
application's log — and delivering all
ten of its existing lines as records,
with an honest account of where a tail
starts reading and why.

## The fixture

`fluent-bit-lab/fixtures/app.log` is
ten lines of JSON, one event per line,
from an invented ticket-desk
application:

```
{"ts":"2026-11-07T09:00:01Z","level":"INFO","service":"ticket-desk","ticket":101,"message":"ticket created"}
{"ts":"2026-11-07T09:00:04Z","level":"ERROR","service":"ticket-desk","ticket":103,"message":"payment gateway timeout"}
```

Levels run INFO, DEBUG, and ERROR;
chapters 6 and 7 spend them. The full
pipeline for this chapter is
`fluent-bit-lab/configs/t02-tail-parse.conf`:

```
[INPUT]
    Name              tail
    Path              ../fixtures/app.log
    Tag               app.json
    DB                ../outputs/t02.db
    DB.Sync           Full
    Refresh_Interval  1
    Skip_Long_Lines   On
    Inotify_Watcher   false
    Read_From_Head    true
```

The settings that matter:

- **Path** — the file (or wildcard
  pattern) to follow.
- **DB** — a small database file where
  Fluent Bit remembers, per file, how
  far it has read. On a restart it
  resumes at the remembered offset
  instead of re-reading or skipping.
  `DB.Sync Full` asks the operating
  system to confirm each write of that
  position.
- **Inotify_Watcher false** — check the
  file by polling (`Refresh_Interval`)
  instead of kernel file events. Polling
  is slower to notice changes and works
  on filesystems that cannot offer
  events; the lab used it so runs were
  deterministic.
- **Skip_Long_Lines On** — a line longer
  than the buffer is skipped rather
  than stopping the file's monitoring.

## Where a tail starts: a 5.1.5 lesson

The lab's first runs delivered
*nothing* from the existing file — no
error, and no records. The reason is a
default worth knowing by name: in
5.1.5, the tail input starts reading a
file it discovers at startup from the
**end** of the file, like the Unix
`tail -f`. Lines already present are
history, and a forwarder that starts
by re-sending history can flood a
destination with duplicates after every
restart.

`Read_From_Head true` is the explicit
exception: read a newly discovered
file from its first line. With it set,
the lab's run delivered all ten lines.
In real deployments the distinction is
the whole game:

- A brand-new log file, written after
  Fluent Bit starts, is read from its
  head by default
  (`read_newly_discovered_files_from_head`
  defaults to true in the tail help).
- A file that already exists at
  startup is followed from its end —
  unless you ask for the head, or a DB
  offset from a previous run tells it
  where it left off.

## What tail hands over

Without a parser, each line arrives as
one field named `log` — the tail
input's default key — holding the raw
line as a string. Chapter 6 applies the
parser that turns it into fields. The
finished output of this chapter's
pipeline (parser included) is
`fluent-bit-lab/outputs/t02-parsed.log`;
its first line:

```
app.json: [1794042001.000000000, {"level":"INFO","service":"ticket-desk","ticket":101,"message":"ticket created"}]
```

Note the timestamp: 1794042001 is the
fixture line's own `ts` field —
2026-11-07T09:00:01Z — not the moment
Fluent Bit happened to read it. A
parser that carries a time key replaces
arrival time with event time. Chapter 6
shows what a record looks like when no
time was parsed: it keeps its arrival
timestamp instead, and the difference
is visible side by side.

Check: point the tail configuration at
the fixture, run it, and count the
output file's lines: 10. Remove
`Read_From_Head` (with no DB file
present) and the count is 0 — the two
results together are the chapter.
