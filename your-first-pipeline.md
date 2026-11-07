# Your first pipeline

Outcome: a pipeline that runs, with a
known number of records in and the same
number out — the smallest honest proof
that configuration, tags, and Match all
line up.

## A record source that cannot lie

The `dummy` input invents records. Give
it a sample count and it produces
exactly that many, one per second at
`Rate 1`, and stops — which makes it
the right first source: any mismatch
between what it made and what arrived
is the pipeline's fault, never the
data's. The lab's first configuration
(`fluent-bit-lab/configs/t01-dummy.conf`):

```
[SERVICE]
    Flush        1
    Log_Level    info
    Parsers_File parsers.conf

[INPUT]
    Name   dummy
    Tag    test.dummy
    Dummy  {"message":"hello from dummy","service":"ticket-desk"}
    Rate   1
    Samples 5

[OUTPUT]
    Name   stdout
    Match  test.dummy
```

Read it as the three steps from
chapter 1. The input makes records
tagged `test.dummy`. The output prints
records to the screen — but only ones
whose tag matches `test.dummy`.

Run it (the lab let it run until the
records were out, then stopped it):

```
fluent-bit -c t01-dummy.conf
```

## Reading the result

Fluent Bit prints its banner, then its
own log lines, then the records
(transcript
`fluent-bit-lab/transcripts/t01-dummy-stdout.txt`):

```
[0] test.dummy: [[1794088195.418315688, {}], {"message"=>"hello from dummy", "service"=>"ticket-desk"}]
[1] test.dummy: [[1794088196.418285585, {}], {"message"=>"hello from dummy", "service"=>"ticket-desk"}]
```

Each line is one record: its tag, its
timestamp in brackets, and its fields.
The count is the check:

```
$ grep -c "hello from dummy" t01-dummy-stdout.txt
5
```

Five requested, five delivered. Change
`Samples` to 3 and the count becomes 3;
change the output's `Match` to
`test.other` and the count becomes 0 —
no error, no warning, just silence.
That silence is the one rule from
chapter 1 in miniature: routing happens
at flow time, and a record that matches
nothing is gone, not queued for a
better-configured future.

## The same pipeline in YAML

Fluent Bit 5.1.5 also reads the YAML
configuration format. The lab verified
that rather than assuming it: the same
pipeline as `t01-dummy.yaml`, with
`samples: 3`, produced exactly 3
matching records (transcript
`t01b-dummy-yaml.txt`):

```yaml
service:
  flush: 1
  log_level: info
  parsers_file: parsers.conf

pipeline:
  inputs:
    - name: dummy
      tag: test.dummy
      dummy: '{"message":"hello from dummy yaml","service":"ticket-desk"}'
      rate: 1
      samples: 3

  outputs:
    - name: stdout
      match: test.dummy
```

This guide teaches the classic format —
most existing configurations in the
wild use it — but nothing in the later
chapters depends on the choice.

## Stopping

Fluent Bit runs until stopped. Ctrl-C,
or `SIGTERM` from a service manager,
shuts it down in order: inputs pause,
pending chunks get a grace period (the
lab's transcripts show "service will
shutdown in max 5 seconds"), and the
engine reports how it stopped. A
pipeline is a long-running service,
not a batch job; chapter 12 covers
what happens to undelivered chunks
across that shutdown.

Check: run the dummy pipeline with
`Samples 4`, and count 4 records at the
output. Then change only the output's
`Match` and watch the count fall to 0
with no error. Both halves are the
lesson.
