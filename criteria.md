# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The lab's traffic is the lab talking to itself.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** The limits chapter names what the
   tool cannot do: it forwards and shapes records but does not
   store them long-term or answer queries over them; a parser
   that does not match silently passes records through unparsed
   (demonstrated in the lab, chapter 6); backpressure and
   filesystem buffering have real limits — a capped number of
   waiting chunks, retry limits after which chunks are dropped
   (demonstrated, chapter 12); and it is not a metrics database
   or an alerting tool, however many counters it exposes about
   itself.
8. **The one rule is in the text, early.** Chapter 1 and the
   README state the rule plainly — *Fluent Bit is a river, not
   a lake: records flow through it once, shaped by the filters
   they pass, and anything you did not parse, tag, or route
   correctly at flow time is not waiting for you downstream* —
   before any procedure depends on it, and later chapters point
   back to it where the rule bites: the silently unparsed line,
   the tag that matches nothing, and the chunk dropped when its
   retries ran out.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The build machine is an Ubuntu 24.04 sandbox. Fluent Bit
**5.1.5** was the project's official Ubuntu package for noble
(`fluent-bit_5.1.5_amd64.deb`, 63186770 bytes, md5
edf3825bcdd1e8dd9952682f47647507, from
packages.fluentbit.io/ubuntu/noble/), **extracted** with
`dpkg-deb -x` into lab scratch and run from there — not
installed system-wide; no `fluent-bit` package was installed
on this machine. The lab is in `fluent-bit-lab/`: fixtures for
a fictional ticket-desk application (a ten-line JSON log, a
five-line plain-text log with one malformed line, a stack
trace log, and one HTTP payload), the parsers file and every
pipeline configuration the chapters use (`configs/`), two
driver scripts (`drivers/`), the file outputs the chapters
quote (`outputs/`), and transcripts of every run
(`transcripts/`). All network work was loopback: the HTTP
input bound 127.0.0.1:18084 and the monitoring server
127.0.0.1:19084.

Run for real, with transcripts as evidence:

- Version and the full `--help` text, captured before anything
  else was trusted (t00). The binary is the official package's
  own `/opt/fluent-bit/bin/fluent-bit`, run from the extraction
  folder.
- The first pipeline (t01): dummy input to stdout output in
  the classic configuration format produced exactly **5**
  records for `Samples 5`. The same pipeline in the YAML
  format (t01b) produced exactly **3** for `samples: 3` —
  YAML support on 5.1.5 was verified, not assumed.
- The real pipeline, parse stage (t02): tail of the JSON
  fixture plus the JSON parser filter produced a file of
  **10** records with `level`, `service`, `ticket`, and
  `message` extracted and each record's timestamp taken from
  its own `ts` field. Finding recorded in chapter 5: without
  `Read_From_Head true` (and no prior DB), the same run
  delivered 0 records — 5.1.5's tail starts existing files at
  their end.
- The regex parser (t04): four of five plain-text lines parsed
  into fields with event timestamps; the fifth, malformed line
  passed through **unparsed and without any error**, carrying
  only its raw `log` field and its arrival timestamp.
- Filtering and shaping (t03): a modify filter (Add
  `pipeline`, Rename `message` to `event`) and a grep filter
  (`Exclude $level DEBUG`) reduced the same 10 records to
  **7** — 4 INFO and 3 ERROR, the 3 DEBUG records dropped.
  Counts before and after are in t10.
- Multiline (t05): the multiline parser defined in the lab's
  parsers file folded the 8-line stack trace fixture into
  **3** records, the ERROR record containing the full trace.
  The older `Multiline On` form failed at startup on 5.1.5
  with "multiline: no parser defined for firstline" (t05b),
  and the chapter says so.
- HTTP in and monitoring (t06): a curl POST of one JSON record
  to the HTTP input on 127.0.0.1:18084 returned **201
  Created** and the record appeared in the file output. The
  monitoring server on 127.0.0.1:19084 answered
  `/api/v1/uptime` and `/api/v1/metrics` (and the Prometheus
  form, reporting the input's 92 bytes after the POST).
  `/api/v1/health` returned **404** on this version; the
  chapter reports that rather than assuming the endpoint.
- Routing (t07): two dummy inputs tagged `app.web` (2 samples)
  and `app.worker` (3 samples) reached two different file
  outputs with counts **2** and **3** and no records in the
  wrong file.
- Buffering and retries (t08): an HTTP output pointed at a
  dead endpoint (127.0.0.1:19084, nothing listening) logged
  "no upstream connections available" and retry warnings with
  growing delays (7, 11, 15, 19, 32 seconds), then "cannot be
  retried" for both chunks once `Retry_Limit 3` was exhausted
  — inside a bounded 25-second run. With filesystem buffering
  (t08b), two 4096-byte `.flb` chunk files were listed under
  the storage path while retries were pending.
- Troubleshooting evidence (t09): a configuration naming a
  nonexistent output failed at startup with "section
  'no_such_output' tried to instance a plugin name that
  doesn't exist" and exit code 1; `--dry-run` passed the good
  pipeline ("configuration test is successful") and failed
  the broken one; `storage.type` placed on an output produced
  the "unknown configuration property" error naming the
  allowed properties. Early in the build the parser filter
  likewise rejected an unsupported property by name; the lab
  removed it and the error is described in chapter 16.

Documented only — described from the project's `--help` text
and manual, not run, and the text does not claim otherwise:

- Installation routes other than extracting the official
  .deb (the install script, apt repositories used as
  repositories, container images, source builds) and
  everything Windows- or macOS-specific.
- Outputs other than stdout, file, and http — including the
  search, object-storage, and queue services, and the
  `forward` and `null` outputs — characterised in chapter 11,
  not connected to.
- The modify filter's operations beyond Add and Rename; the
  grep filter's `Grep` (keep-only) form is described from the
  plugin's documented behaviour, not run as a pipeline of its
  own — `Exclude` is the form the lab ran.
- Built-in multiline parsers (Docker, CRI, Go, Java, and
  others); the lab defined and ran its own.
- Stream processing, hot reload, chunk tracing, the daemon
  and supervisor modes, and Kubernetes-specific inputs and
  filters.
- The neighbouring tools in chapter 14 are characterised, not
  benchmarked.
- One statement in chapter 12 — that delivery resumes when an
  endpoint returns mid-retry — is flagged in the text itself
  as observed while building the lab, not transcript-verified.

Fixtures are this guide's own and deliberately generic: an
invented ticket-desk application and its logs, an invented
stack trace, and one invented HTTP payload. No example is
modelled on any real person, network, service or
organisation. Two accidents of the build are kept in the
record because the chapters teach from them: the tail input's
seek-to-end default cost the lab its first two runs before
`Read_From_Head` was found in the plugin's own help, and the
filesystem-buffering error (a property placed on the wrong
plugin) is preserved as a troubleshooting transcript.
