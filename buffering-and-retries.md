# Buffering and retries

Outcome: a delivery failure watched
end to end — the retry log with its
growing delays, the moment Fluent Bit
gives up, and the chunk files that
filesystem buffering leaves on disk —
so the promises in this area are ones
you have seen kept and seen expire.

## The experiment

Configuration
`fluent-bit-lab/configs/t08-retry.conf`
generates two dummy records and sends
them with the `http` output to
`127.0.0.1:19084` — where, in this test,
*nothing was listening* — with
`Retry_Limit 3`. The run is bounded:
the lab stopped it after 25 seconds
(transcript `t08-retry.txt`).

## What Fluent Bit logs

The failure is neither silent nor
instant. Each flush attempt fails, and
the scheduler retries with delays that
grow:

```
[error] [output:http:http.0] no upstream connections available to 127.0.0.1:19084
[ warn] [engine] failed to flush chunk '172629-1794088455.395362619.flb', retry in 7 seconds: task_id=0, input=dummy.0 > output=http.0 (out_id=0)
[ warn] [engine] failed to flush chunk '172629-1794088456.395317223.flb', retry in 11 seconds: task_id=1, input=dummy.0 > output=http.0 (out_id=0)
[ warn] [engine] failed to flush chunk '172629-1794088455.395362619.flb', retry in 15 seconds: task_id=0, input=dummy.0 > output=http.0 (out_id=0)
```

Each record batch is its own task with
its own retry count and its own
schedule — 7 seconds, then 15, then
32 for the first chunk. And the count
runs out. Inside the same 25 seconds:

```
[error] [engine] chunk '172629-1794088455.395362619.flb' cannot be retried: task_id=0, input=dummy.0 > output=http.0
[error] [engine] chunk '172629-1794088456.395317223.flb' cannot be retried: task_id=1, input=dummy.0 > output=http.0
```

After `Retry_Limit`, the chunks are
**dropped**. The records are gone.
Fluent Bit said so, in its log, at
error level — and that log line is the
only trace they leave. This is the one
rule's hardest edge: a forwarder's
buffering is a bridge across a short
outage, not a warehouse for a long
one. How long the bridge is — flush
interval, retry limit, the backoff
between attempts — is your arithmetic,
done in advance, against the outages
you actually expect.

## Where the waiting chunks live

By default, chunks wait in **memory**:
fast, and lost if the process dies.
With filesystem buffering they wait on
disk. Configuration `t08b-fs-buffer.conf`
sets `Storage.Path` on the service and
`storage.type filesystem` on the input
(chapter 2: the setting belongs to the
input; putting it on the `http` output
earns a precise startup error, quoted
in chapter 16). The driver
`run-t08b-fs-buffer.sh` listed the
storage folder *while* the endpoint was
down and retries were pending
(transcript `t08b-fs-buffer-files.txt`):

```
.../outputs/fsbuffer/dummy.0/172939-1794088526.395434540.flb
.../outputs/fsbuffer/dummy.0/172939-1794088527.395351488.flb
-rw------- 1 root root 4096 ... 172939-1794088526.395434540.flb
-rw------- 1 root root 4096 ... 172939-1794088527.395351488.flb
```

One `.flb` file per waiting chunk,
named for the chunk in the retry log.
Filesystem chunks survive a restart —
on startup a backlog mechanism replays
what an earlier run could not deliver —
and they can fill a disk, which memory
chunks cannot. Neither kind is
unbounded: the service caps how many
chunks may be waiting (`max_chunks_up`,
128 in the lab's startup log), and an
input can be given a memory limit
(`Mem_Buf_Limit`) at which it pauses.
Backpressure is real, and it has edges;
chapter 15 collects them.

A related honesty: when the endpoint
came back *during* a retry window in
preparation runs, delivery simply
resumed — but this guide did not keep a
transcript of a mid-outage recovery,
so it is stated here as behaviour
observed while building the lab, not
as a verified claim. The verified
claims are the retry log and the chunk
files above.

Check: point the HTTP output at a dead
port, and read your own retry log: the
growing delays, and then "cannot be
retried". Say out loud where those
records are now. (Nowhere.) That answer
is the chapter.
