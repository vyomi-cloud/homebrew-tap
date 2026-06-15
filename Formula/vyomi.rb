# Homebrew formula for Vyomi — the local multi-cloud simulator appliance.
#
# Tap install (recommended):
#   brew tap vyomi-cloud/tap
#   brew install vyomi
#
# Legacy alias (for users coming from CloudLearn):
#   brew install cloud-learn   # resolved via Aliases/cloud-learn → vyomi
#
# Direct install (no tap):
#   brew install --HEAD https://github.com/vyomi-cloud/appliance.git
#
# This formula is auto-updated by .github/workflows/release.yml on every
# v*.*.* tag — the url + sha256 are bumped to the tarball published with
# the GitHub Release, then committed to vyomi-cloud/homebrew-tap.

class Vyomi < Formula
  desc "Local multi-cloud simulator (AWS/GCP/Azure) with real backends"
  homepage "https://vyomi.cloud"
  url "https://github.com/vyomi-cloud/appliance/releases/download/v2.0.0/cloud-learn-2.0.0.tar.gz"
  sha256 "78e513925957a42027ab3133367036ddaf453f09cdba6d18c7fbbfe9c1e809bb"
  license :cannot_represent  # BSL 1.1 — not in SPDX simple form
  version "2.0.0"

  # Note: multipass and Docker Desktop ship as casks, not formulae, so we
  # can't `depends_on` them directly from a Formula. They're listed in
  # `caveats` instead — users install them via `brew install --cask`, OR
  # `vyomi up` itself offers to install Multipass automatically on first
  # launch (see maybe_install_multipass in scripts/cloud-learn).

  def install
    # Ship the launcher + the appliance compose + the source the appliance VM
    # syncs in as /workspace/cloud-learn.
    libexec.install Dir["*"]

    # Wrapper that sets CLOUD_LEARN_HOME and shells into the bundled launcher.
    # NOTE for Phase 6: the binary name `cloud-learn` will be renamed to
    # `vyomi` with a shim in a later release. Today both still ship as
    # `cloud-learn` for backwards-compat with existing user muscle memory.
    (bin/"cloud-learn").write <<~EOS
      #!/usr/bin/env bash
      export CLOUD_LEARN_HOME="#{libexec}"
      export CLOUDLEARN_DISTRIBUTION_MODE="appliance"
      exec bash "#{libexec}/scripts/cloud-learn" "$@"
    EOS
    chmod 0555, bin/"cloud-learn"

    # Bash + zsh completions (lightweight; just lists the subcommands)
    (bash_completion/"cloud-learn").write <<~EOS
      _cloud_learn() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local cmds="up down stop restart status doctor help"
        COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
      }
      complete -F _cloud_learn cloud-learn
    EOS
  end

  def caveats
    <<~EOS
      Vyomi ships as an appliance — it starts a single Multipass VM
      and runs the full simulator stack (FastAPI + 8 real backends) inside.

      Prerequisites:
        • Multipass         (auto-installed by `cloud-learn up` on first run,
                             OR install manually: brew install --cask multipass)
        • Docker            (runs INSIDE the VM, not on your Mac)
        • ~32 GB free disk  (VM image + container layers)

      Get started:
        cloud-learn up                       # boots VM + simulator (5-10 min first run)
        open http://vyomi.local:9000         # URL printed in the launcher banner

      Stop with:
        cloud-learn down

      Full docs:
        https://vyomi.cloud/install
    EOS
  end

  test do
    # `cloud-learn help` runs without needing Multipass or Docker present.
    assert_match "cloud-learn", shell_output("#{bin}/cloud-learn help 2>&1", 0)
  end
end
