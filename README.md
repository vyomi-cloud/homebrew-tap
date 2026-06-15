# Vyomi Homebrew Tap

Homebrew formula + tap for [Vyomi](https://vyomi.cloud) — the local multi-cloud simulator appliance.

## Install

```bash
brew tap vyomi-cloud/tap
brew install vyomi
```

The legacy `cloud-learn` name continues to work via an alias:

```bash
brew install cloud-learn   # same package as `brew install vyomi`
```

Both invocations install the same binary, currently named `cloud-learn` (will be renamed to `vyomi` in a later release with a `cloud-learn` shim).

## After install

```bash
cloud-learn up                       # first run: boots Multipass VM + Docker stack inside (~5-10 min)
open http://vyomi.local:9000         # URL printed by the launcher
```

See [vyomi.cloud/install](https://vyomi.cloud/install) for the full guide.

## Source

The formula here is auto-bumped by [`vyomi-cloud/appliance`](https://github.com/vyomi-cloud/appliance)'s `.github/workflows/release.yml` on every `v*.*.*` tag. Direct edits to `Formula/vyomi.rb` get overwritten — change the [source-controlled template in the appliance repo](https://github.com/vyomi-cloud/appliance/blob/main/packaging/homebrew/Formula/vyomi.rb) instead.
