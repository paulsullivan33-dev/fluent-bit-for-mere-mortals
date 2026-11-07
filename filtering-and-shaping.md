# Filtering and shaping

Outcome: the ten parsed ticket-desk
records reduced to the seven that
matter, with fields renamed and added
on the way — and the counts, before and
after, to prove exactly what the
filters did.

## Order is the whole trick

Filters run in configuration order, and
the pipeline in
`fluent-bit-lab/configs/t03-filtered.conf`
is ordered for a reason:

1. `parser` first — nothing downstream
   can test a field that does not exist
   yet.
2. `modify` — reshape the record.
3. `grep` — decide which records
   continue.

Swap 1 and 3 and `grep` would test
`$level` on records that have no
`level` field; every record would fail
the test in one direction or the other,
quietly (chapter 1's rule again).

## modify: add and rename

```
[FILTER]
    Name    modify
    Match   app.json
    Add     pipeline fluent-bit-lab
    Rename  message event
```

`Add` attaches a new field with a fixed
value — provenance, in this case: which
pipeline shaped the record. `Rename`
moves a field to a new name; downstream
systems that expect `event` rather than
this application's `message` get it,
once, at flow time. The modify filter
also offers `Remove`, `Set`, `Copy`,
and more, named in its help
(`fluent-bit -F modify -h`);
documented-only here.

## grep: keep and drop

```
[FILTER]
    Name    grep
    Match   app.json
    Exclude $level DEBUG
```

`Exclude` drops any record whose field
matches. The complementary form,
`Grep $level ERROR`, would keep *only*
matching records and drop the rest.
Either way, the decision is final:
a dropped record is not filed anywhere
for later review. Dropping is a policy
decision — debug lines are cheap to
lose in this lab and expensive to store
for a year — and the river does not
second-guess it.

## The counts

Before filtering, chapter 6's pipeline
delivered **10** records to its file.
This pipeline delivers **7**
(`fluent-bit-lab/outputs/t03-filtered.log`,
transcript `t03-filtered.txt`; both
counts are in
`fluent-bit-lab/transcripts/t10-counts-summary.txt`):

```
app.json: [1794042001.000000000, {"level":"INFO","service":"ticket-desk","ticket":101,"event":"ticket created","pipeline":"fluent-bit-lab"}]
app.json: [1794042004.000000000, {"level":"ERROR","service":"ticket-desk","ticket":103,"event":"payment gateway timeout","pipeline":"fluent-bit-lab"}]
```

The arithmetic is the audit: 10 in,
3 DEBUG records dropped, 7 out — 4 INFO
and 3 ERROR. Every kept record shows
both shapings: `message` became
`event`, and `pipeline` was added.
Counting before and after is not
ceremony. It is the only way to know a
filter did what you *meant*, rather
than something adjacent to it — a
filter that dropped everything, or
nothing, also exits without complaint.

Check: run both configurations and
reproduce the counts — 10, then 7.
Change the Exclude line to `Exclude
$level ERROR` and predict the new count
before you run it (7 again — but a
different 7: INFO plus DEBUG). If your
prediction matches, the filters are
doing what you think.
