# Glossary

The terms, collected in one place.
Each definition is the one the chapters
used.

**Backpressure** — what happens when
records arrive faster than they can be
delivered: buffers fill, inputs pause
at their limits, and past the limits,
records are dropped. Chapter 12.

**Buffering** — holding records that
cannot be delivered yet, in memory
(default) or on disk (filesystem
buffering), while retries proceed.

**Chunk** — the batch in which records
travel to an output. One failed
delivery is one chunk failing; chunk
names appear in the retry log and, with
filesystem buffering, as `.flb` files.

**DB (tail)** — the tail input's
database file, remembering how far it
has read in each file, so restarts
resume instead of repeating or
skipping. Chapter 5.

**Dummy input** — an input that invents
records at a set rate and sample count.
The lab's measuring stick: what it made
is known exactly, so the pipeline's
behaviour can be checked exactly.

**Exclude / Grep** — the grep filter's
two forms: `Exclude` drops records
whose field matches; `Grep` keeps only
records whose field matches.

**Field** — one named value inside a
record: `level`, `ticket`, `message`.
Parsers create fields; filters test and
reshape them.

**Filter** — a pipeline stage that sees
records matching its Match pattern and
may parse, modify, keep, or drop them,
in configuration order.

**Flush** — one delivery attempt by an
output; also the service setting
(`Flush`) for how often outputs attempt
delivery.

**Input** — the plugin where records
are born: `tail`, `http`, `dummy`,
`systemd`, and the rest of the list in
`fluent-bit --help`.

**Match** — an output's (or filter's)
tag pattern. Only records whose tag
matches are received. Exact, or with
`*` wildcards.

**Multiline parser** — a small state
machine that folds continuation lines
into the record they belong to, so a
stack trace travels as one record.
Chapter 8.

**Output** — the plugin that delivers
records to a destination: `file`,
`stdout`, `http`, and many services.

**Parser** — a named pattern (JSON, or
a regular expression) that turns a raw
string into fields, optionally carrying
the event's own time via `Time_Key`.

**Record** — the unit that flows: a
timestamp, a tag, and a set of fields.

**Reserve_Data** — a parser-filter
setting: keep the fields the parser
found in the record.

**Retry_Limit** — how many times an
output may retry a failed chunk before
the chunk is dropped and the loss is
logged. Chapter 12.

**storage.type** — an input setting:
`memory` (default) or `filesystem` for
that input's chunks. Set on the service
side by `Storage.Path`, which gives the
filesystem chunks a home.

**Tag** — the label an input stamps on
every record it makes. Routing is tags
plus Match patterns and nothing else.

**Tail** — the input that follows
files. On 5.1.5 it starts existing
files at their end unless
`Read_From_Head` is set or a DB offset
says otherwise.

Check: pick any five terms and define
them without looking back. Then look
back — the misses are your revision
list.
