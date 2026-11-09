# Changelog

All notable changes to this fork are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Based on the `dev` branch of
  [packetflinger/opentdm](https://github.com/packetflinger/opentdm), with its
  many crash and bug fixes, player swapping, `#t`/`#T` chat macros, the
  `mix` vote alias, the improved server fps handling, and match stats sent
  as JSON to a stats server (`g_send_stats`, `g_stats_url`,
  `g_stats_token`).
- `g_aimfix` aims shots at the point under the crosshair instead of straight
  ahead from the weapon. Off by default.
- Prebuilt game libraries for Linux x86_64 and ARM64 and for 32-bit and 64-bit
  Windows, published with every release.

### Changed

- The Windows DLLs no longer need any DLLs next to them: libcurl is linked
  statically and uses the TLS support built into Windows.
- The Linux libraries use the system libcurl instead of a copy of curl and
  OpenSSL from 2023 built into them, so they get security updates from the
  distribution.
- Match stats ids are hashed with a built-in MD5 instead of OpenSSL; the ids
  are unchanged.
