# Installing Fluent Bit

Outcome: Fluent Bit installed — or, as
in this guide's lab, obtained without
installing — and the version check run,
so every later chapter's output can be
trusted to come from a known version.

## What the lab used

The lab ran **Fluent Bit 5.1.5**, the
current release at the time of writing,
as the project's official Ubuntu
package:

```
fluent-bit_5.1.5_amd64.deb
from https://packages.fluentbit.io/ubuntu/noble/
(the noble / Ubuntu 24.04 repository)
size 63186770 bytes
md5  edf3825bcdd1e8dd9952682f47647507
```

The package was *extracted*, not
installed — no system files were
touched:

```
dpkg-deb -x fluent-bit_5.1.5_amd64.deb extracted/
extracted/opt/fluent-bit/bin/fluent-bit --version
```

```
Fluent Bit v5.1.5
```

(transcript
`fluent-bit-lab/transcripts/t00-version.txt`).
The binary lands at
`/opt/fluent-bit/bin/fluent-bit` in a
real install; the lab ran the same path
inside its extraction folder. The full
`--help` text — options, and the lists
of input, filter, and output plugins
this version carries — is transcript
`t00-help-full.txt`, captured before
anything else was trusted.

## The ordinary routes

On your own machine, the ordinary
routes are documented-only in this
guide (named here, not run):

- The project's one-line install script
  for Linux, which adds the official
  package repository and installs the
  `fluent-bit` package with your
  distribution's package manager.
- The official repositories directly:
  `packages.fluentbit.io` serves
  packages for Ubuntu, Debian, CentOS,
  and others, signed with the project's
  key.
- Container images from the project's
  registry, and builds from source, for
  the cases the packages do not cover.

Whichever route you take, the package
installs the program at
`/opt/fluent-bit/bin/fluent-bit`, a
default configuration under
`/etc/fluent-bit/`, and a service
definition for your init system.

## The version check

Whatever you installed, run this before
believing anything else in the guide:

```
/opt/fluent-bit/bin/fluent-bit --version
/opt/fluent-bit/bin/fluent-bit --help
```

Two habits are worth forming now.
First, plugin property names and
defaults change between versions —
this guide found two in 5.1.5 alone
(chapters 5 and 8) — so a procedure
written for another version is a
starting point, not a promise. Second,
every plugin documents itself:

```
fluent-bit -i tail -h      # one input's properties
fluent-bit -F parser -h    # one filter's
fluent-bit -o http -h      # one output's
```

The error messages in chapter 16 point
at exactly these commands when a
property name is wrong.

Check: `fluent-bit --version` prints a
version you can name, and `fluent-bit
-i tail -h` prints the tail input's
property list. If both do, your install
is real and this guide's lab matches
its shape.
