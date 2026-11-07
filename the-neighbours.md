# The neighbours

Outcome: the adjacent tools placed
honestly next to Fluent Bit —
characterised, not benchmarked — so a
reader choosing a collector knows what
each one's centre of gravity is.

## Fluentd

Fluent Bit's older sibling in the same
project family. Fluentd is written in
Ruby, runs heavier, and carries a vast
plugin ecosystem and a long history in
servers and Kubernetes. The family's
usual arrangement: Fluent Bit at the
edge, on every node, forwarding to
Fluentd aggregators that do heavier
processing. If you need an exotic
plugin or transformation that exists
only for Fluentd, that is a real
reason; for plain collection and
forwarding, the smaller tool is the
usual answer.

## Logstash

The Elastic family's collector: a JVM
program with a powerful pipeline
language (grok patterns, conditionals,
rich transformations) and a matching
appetite for memory. Strong when your
destination is Elasticsearch and your
parsing is genuinely complex; heavy for
"tail this file and forward it". Fluent
Bit also has an Elasticsearch output,
so the destination alone does not force
the choice — the transformation
complexity does.

## Vector

A single-binary collector written in
Rust, with its own transformation
language and a reputation for clean
configuration. The closest neighbour in
spirit: same job, similar footprint
class, different ecosystem and syntax.
Choosing between Vector and Fluent Bit
is usually about which one's plugins,
documentation, and community fit your
surroundings better — both are honest
tools for the river's work.

## Filebeat

Elastic's lightweight shipper, narrower
by design: excellent at tailing files
and feeding the Elastic stack, with
modules for common log formats, and
much less of a general processor than
the tools above. If your world is
Elastic end to end, its narrowness is
a feature.

## syslog-ng and rsyslog

The elders. Both predate the current
wave, both are already installed on
more machines than everything else in
this chapter combined, and both collect
and forward logs — especially anything
speaking syslog — with deep,
battle-tested configuration. If your
records are syslog-shaped and your
team knows these tools, that knowledge
is worth more than a newer name.

## The OpenTelemetry Collector

A vendor-neutral collector for logs,
metrics, and traces under the
OpenTelemetry standard, configured as
receivers, processors, and exporters —
the same input/filter/output shape as
this guide, drawn larger. It is the
natural meeting point when
observability data must be standardised
across vendors, and it interoperates
with Fluent Bit rather than only
competing with it.

None of these neighbours changes the
one rule. Every forwarder on this page
shapes at flow time and stores nothing
worth querying; the differences are
weight, language, ecosystem, and where
each one's community has dug in.

Check: for each neighbour, say its
centre of gravity in a few words —
ecosystem, transformation power,
language and weight, narrowness,
seniority, standardisation. If one of
them fits your situation better than
Fluent Bit does, this chapter has done
its job.
