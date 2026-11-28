# Changelog

All notable changes to this fork are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.1] - 2026-11-28

### Fixed

- `maplist` no longer drops the client with an overflow on servers with a
  large maplist: every reply stays below about 2.8 KB. `maplist <text>`
  searches the maplist and `maplist all [page]` browses it 150 maps at a time.

### Added

- An optional second column in the `g_maplistfile` file: `1` marks a map as
  vote-only. Such maps can still be voted (`vote map <name>`), but plain
  `maplist` only counts them and the vote menu skips them. Lines starting with
  `#` or `//` are comments.

## [1.1.0] - 2026-11-21

### Added

- Re-release hit markers: the damage a player deals is sent to them as
  `TE_DAMAGE_DEALT` once per server frame, but only when their userinfo has
  `cl_hit_markers` above 0, as the MashedD Q2PRO fork sends it. Other
  clients, such as older Q2PRO and R1Q2, drop the connection on that temp
  entity, so they never get it.
- `g_hit_sound` plays a sound to the clients without hit markers when they
  hit someone. Empty by default, so they get nothing.

## [1.0.0] - 2026-11-09

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
