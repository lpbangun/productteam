# Dependency and packaging report

## Canonical CLI

No framework runtime dependency added. The repaired path remains Bash plus the repository’s documented command-line tools. `help --json` and `status --json` are one-shot outputs; plain files remain authoritative.

## Ink spike

- Packages: `ink@7.1.1`, `react@19.2.0`; 39 installed package-tree paths; 22,860 KiB `node_modules`.
- Runtime: Ink declares Node `>=22`; this conflicts with the repository’s conservative Node 18+ portability default.
- Build: none in the spike; ESM and `React.createElement` run directly.
- Packaging: requires distributing a Node 22 runtime and npm dependency tree.
- Measured snapshot: 3.35 s, 254,860 KiB max RSS while loading live CLI data.
- Tests: 35/35, including live adapter, narrow widths, Unicode, NO_COLOR, non-TTY refusal.

## OpenTUI spike

- Package: `@opentui/core@0.5.1`; 14 installed package-tree paths; 81,468 KiB `node_modules` on Linux x64.
- Runtime: live renderer refused Node 22.22.3. It launched with Bun 1.3.14. Package guidance also permits Node >=26.4 with experimental FFI.
- Native packaging: optional packages exist for Darwin arm64/x64, Linux arm64/x64 glibc and musl, and Windows arm64/x64. The installed Linux tree included native core packages.
- Build: no application compile step, but distribution carries native renderer binaries and an FFI runtime.
- Measured snapshot: 2.92 s, 253,716 KiB max RSS. Snapshot uses the shared view model and does not load the native renderer.
- Tests: 31/31, including live adapter, narrow widths, Unicode, NO_COLOR, non-TTY refusal.

## Policy result

No dependency survives. Both prototype directories, lockfiles, package manifests, and `node_modules` are deleted after evidence capture. No package cache or generated dependency is retained. Future adoption requires explicit optional packaging, a supported runtime matrix, signal/process-tree proof with real provider execution, accessibility evidence, and net deletion evidence.
