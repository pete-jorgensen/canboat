# CANboat — proprietary-PGN decode branch

This is a fork of **[canboat/canboat](https://github.com/canboat/canboat)**.

Branch `Decode-In-Progress-HyperActiveJ` carries structural decodes for manufacturer
proprietary PGNs that upstream does not define yet. Branch `master` mirrors
`canboat/canboat` byte for byte and holds nothing of its own.

Everything else about CANboat — what it is, how to build it, how to use `analyzer`
and the gateway drivers, the PGN documentation — lives upstream:

- Source and build instructions: <https://github.com/canboat/canboat>
- PGN documentation: <https://canboat.github.io/canboat>
- Wiki: <https://github.com/canboat/canboat/wiki>

## What this branch adds

**73 proprietary PGN variant definitions, 876 fields**, on top of upstream, plus the
lookups and generated artifacts that go with them. (Counted as the files under
`database/pgns/` that upstream does not have, and the entries of each one's `fields:`
list.)

| Manufacturer | PGNs | Variants | Fields |
| --- | --- | --- | --- |
| Garmin | 61184, 126720 | 48 | 642 |
| Mercury Marine | 130816, 130817, 130821, 130825, 130826, 130830 | 15 | 118 |
| Fusion Electronics | 130820 | 9 | 102 |
| Navico | 130822 | 1 | 14 |

**Garmin, PGNs 126720 and 61184.** Under 126720, thirty autopilot variants decode the
helm-control field records (typed field and field-record families, with and without a
value, single, triple and list forms, plus rudder rate, motor current, voltage and RPM,
and pump PWM), four decode AHRS attitude messages, and twelve more cover the GHC
self-status, node-status and config-table beacons, GHC config key/value entries, a
device-presence master advertisement, a display version/identity handshake, a
button-interface idle beacon, GLM lighting control, GNSS position error and DOP, a
sub-protocol 1502 value, and two GPSMAP data-sync record layouts. Two more variants
are on single-frame PGN 61184: an autopilot keepalive and sub-protocol 555.

**Mercury Marine.** `130816 Alarm` (a fixed header with a fault-record count, followed
by that many 12-byte fault records), `130817 Vessel Configuration`, `130821 Pop-Up
Notification`, and `130830 Single Lever Mode` with a `MERCURY_SINGLE_LEVER_MODE`
lookup covering single-lever, throttle-only, docking and the three SmartCraft
no-comms states. On `130825`, Active Trim Status, the oil-level check command and reset
response, and the maintenance reset command and response. On `130826`, the SmartCraft
calibration record with its tank, trim and trim-tab replies, and the fuel-used reset
and subtract commands.

**Fusion Electronics, PGN 130820.** Nine more message ids: Wi-Fi state, interface IP
setting, IP setting, interface state, DHCP server configuration, network type, LCD
brightness, part number and server info.

**Navico.** `130822 Alert`, the sub-type-2 alert record, alongside upstream's existing
130822 UDB variants.

**Field-level corrections and lookup extensions**

- `VICTRON_VREG` gains registers `0x0100` Product Id (24-bit) and `0x0102` Firmware
  Version (32-bit).
- `127750 Converter Status` gets its 1500 ms transmission interval and is marked
  complete.
- `126720 Garmin: Autopilot Heading to Steer` is an absolute heading on the full
  circle (0 .. 2 pi), not a signed offset; the range minimum is corrected accordingly.

**Regression test.** `analyzer/tests` gains `test1001`, which runs 20 proprietary
frames through `analyzer` and diffs the decode against a checked-in expectation:
Mercury `130824`, `130825` (two opcodes), `130826` and `130829`; Navico `65280`,
`65313`, `130822` (Source Report and Alert) and `130825`; Fusion `130820`
across eight message ids; Victron `61184` across two VREG registers. Of the
definitions listed above it exercises two, Navico `130822 Alert` and Mercury `130826
SmartCraft Calibration, Trim Reply`; the others are not covered by it.

**Generated output is regenerated on the branch**, so the definitions are live for
every consumer: `docs/canboat.json`, `docs/canboat.xml`, `docs/canboat.html`,
`analyzer/pgn-generated-data.h`, `analyzer/lookup-generated-data.h` and the
`canboat-core` Rust schema.

### What that looks like

A Garmin GNSS position-error frame on PGN 126720. Upstream reports the fallback
variant and leaves the payload as bytes:

```
126720 0x1EF00: Manufacturer Proprietary fast-packet addressed:
  Manufacturer Code = Garmin; Industry Code = Marine Industry;
  Data = 17 00 04 04 BF A0 1B 41 5E 14 7F 41 4C 67 95 41 ...
```

On this branch the same frame decodes structurally:

```
126720 Garmin: GNSS Position Error and DOP:
  Manufacturer Code = Garmin; Industry Code = Marine Industry;
  Sub-protocol ID = GNSS position error and DOP; Wrapper Byte 1 = 4;
  Wrapper Byte 2 = 4; Horizontal Position Error = 9.72674 m;
  Vertical Position Error = 15.9425 m; Overall Position Error = 18.6754 m; ...
```

Where a payload's field layout is known but a value enumeration is not, the field is
decoded and left unlabelled rather than guessed at.

## Relation to upstream

Changes meant for `canboat/canboat` are offered there as focused pull requests, one
topic at a time, against upstream's own branch.

**This README describes the fork and is never part of such a pull request.**

## License

CANboat is licensed under the Apache License, Version 2.0. See `LICENSE`.
