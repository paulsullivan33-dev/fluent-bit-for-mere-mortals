# Parsers

Outcome: raw lines turned into named
fields by two parsers — JSON and a
regular expression — and one line that
matches neither, watched closely,
because what Fluent Bit does with it is
the most important behaviour in this
guide.

## Parsers live in their own file

`fluent-bit-lab/configs/parsers.conf`
defines the lab's parsers. The service
loads it with `Parsers_File
parsers.conf`; a parser is then
available by name to any input or
filter.

```
[PARSER]
    Name        json_parser
    Format      json
    Time_Key    ts
    Time_Format %Y-%m-%dT%H:%M:%SZ

[PARSER]
    Name        plain_parser
    Format      regex
    Regex       ^(?<time>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) (?<level>[A-Z]+) (?<service>\S+) ticket=(?<ticket>\d+) (?<message>.*)$
    Time_Key    time
    Time_Format %Y-%m-%d %H:%M:%S
```

`Time_Key` names the field holding the
event's own time, and `Time_Format`
says how to read it; when a parser has
both, the record's timestamp becomes
the event time (chapter 5's output
shows it). The regex parser names its
fields inside the pattern itself —
`(?<level>...)` is the field `level`.

## Applying a parser with a filter

The tail input hands over each line as
a `log` string. The `parser` filter
applies a named parser to that field:

```
[FILTER]
    Name          parser
    Match         app.json
    Key_Name      log
    Parser        json_parser
    Preserve_Key  Off
    Reserve_Data  On
```

`Key_Name` is the field to parse.
`Reserve_Data On` keeps the fields the
parser found (with it off, only the
parsed time would survive).
`Preserve_Key Off` drops the original
`log` string once parsed. The result,
all ten fixture lines, is
`fluent-bit-lab/outputs/t02-parsed.log`:

```
app.json: [1794042001.000000000, {"level":"INFO","service":"ticket-desk","ticket":101,"message":"ticket created"}]
app.json: [1794042004.000000000, {"level":"ERROR","service":"ticket-desk","ticket":103,"message":"payment gateway timeout"}]
```

JSON's types survive: `ticket` is the
number 103, not the string "103".

## The regex parser, and the line that does not fit

`fluent-bit-lab/fixtures/app-plain.log`
is the same application speaking plain
text — four well-formed lines and one
that is not:

```
2026-11-07 09:10:01 INFO ticket-desk ticket=201 user login succeeded
this line does not match the expected pattern at all
```

Run through the `plain_parser` with
`Preserve_Key On` (configuration
`t04-regex-parse.conf`, transcript
`t04-regex-parse.txt`), the output
holds five records. Four are parsed —
fields extracted, timestamps taken from
the line:

```
[0] app.plain: [[1794042601.000000000, {}], {"level"=>"INFO", "service"=>"ticket-desk", "ticket"=>"201", "message"=>"user login succeeded", "log"=>"2026-11-07 09:10:01 INFO ticket-desk ticket=201 user login succeeded"}]
```

(Two differences from the JSON run are
real: a regex parser's fields are all
strings — `"ticket"=>"201"` — and
`Preserve_Key On` keeps the raw `log`
beside them.)

The fifth record is the unmatched line:

```
[3] app.plain: [[1794088344.610790322, {}], {"log"=>"this line does not match the expected pattern at all"}]
```

No error. No warning in the log at the
default level. The record flowed on
with no fields at all and its
*timestamp of arrival* (1794088344, the
lab clock) instead of an event time. A
downstream search for `level = ERROR`
will simply never see such records.
This is the one rule biting exactly as
chapter 1 promised: unparsed at flow
time means unparsed forever, and
silently. If a line format matters to
you, count parsed against unparsed —
Fluent Bit will not do it for you.

Check: run the plain fixture and find
the record whose only field is `log`.
Say why its timestamp differs from its
neighbours'. If you can, you understand
parsers — including the failure mode.
