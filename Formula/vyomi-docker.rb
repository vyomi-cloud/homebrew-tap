# Homebrew formula for vyomi-docker — the Docker-substrate launcher for the
# Free / Lite / Pro tiers. Installs only the `vyomi` wrapper + the pull-only
# docker-compose.cloudlite.yml; `vyomi up` = `docker compose up`. NO Multipass.
#
#   brew tap vyomi-cloud/tap
#   brew install vyomi-docker
#
# For real VMs (Max tier) use the `cloud-learn` formula instead — the two
# conflict (both install a `vyomi` binary).
#
# Auto-updated by .github/workflows/release.yml (url + sha256 + version bumped
# to the release tarball, committed to vyomi-cloud/homebrew-tap).
class VyomiDocker < Formula
  desc "Vyomi (Docker) — Free/Lite/Pro: docker compose up, no Multipass"
  homepage "https://vyomi.cloud"
  url "https://github.com/vyomi-cloud/appliance/releases/download/v3.0.8/cloud-learn-3.0.8.tar.gz"
  sha256 "b852634e8afd0df8544f9f2ef544705781034a06de611454a2f2cfebf340a0a2"
  license :cannot_represent  # BSL 1.1 — not in SPDX simple form
  version "3.0.8"

  conflicts_with "cloud-learn", because: "both install a `vyomi` launcher"

  def install
    # Minimal: the thin Docker wrapper + the pull-only compose file. The
    # wrapper resolves the compose path relative to itself, so the Homebrew
    # share/ layout works without extra config.
    bin.install "packaging/docker/vyomi" => "vyomi"
    (share/"vyomi-docker").install "docker-compose.cloudlite.yml"
  end

  def caveats
    <<~EOS
      vyomi-docker runs the simulator via Docker. Install Docker Desktop first:
        brew install --cask docker

      Then:
        vyomi up      # docker compose up → http://localhost:9000
        vyomi down

      Free/Lite = full API/SDK conformance (no compute); Pro unlocks EC2-on-Docker
      with SSH. For real VMs (Max tier), use the `cloud-learn` formula.
    EOS
  end

  test do
    assert_match "Docker substrate", shell_output("#{bin}/vyomi --help")
  end
end
