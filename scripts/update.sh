#!/usr/bin/env bash
set -euo pipefail

# Update script for custom packages in pkgs/
# Usage: ./scripts/update.sh [package-name]
# Without args, updates all known packages except the pinned Go toolchain.
# Run './scripts/update.sh go' explicitly when crush's go.mod requires a new Go version.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKGS_DIR="$REPO_ROOT/pkgs"

# Placeholder SRI hash used for hashes that must be discovered after a build.
PLACEHOLDER_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

to_sri() {
  local hash="$1"
  nix hash convert --hash-algo sha256 --to sri "$hash"
}

prefetch_url_sri() {
  local url="$1"
  local hash
  hash="$(nix-prefetch-url --type sha256 "$url")"
  to_sri "$hash"
}

# Retry a command a few times to ride out transient network failures.
retry() {
  local attempts="$1"; shift
  local attempt
  for ((attempt = 1; attempt <= attempts; attempt++)); do
    if "$@"; then
      return 0
    fi
    if [[ "$attempt" == "$attempts" ]]; then
      return 1
    fi
    sleep 2
  done
}

prefetch_github_sri() {
  local owner="$1" repo="$2" rev="$3"
  local tmp hash
  tmp="$(mktemp "${TMPDIR:-/tmp}/github-${repo}.XXXXXX.tar.gz")"
  if ! retry 3 gh api "repos/${owner}/${repo}/tarball/${rev}" > "$tmp"; then
    rm -f "$tmp"
    echo "ERROR: failed to download ${owner}/${repo}@${rev} via gh api" >&2
    return 1
  fi
  hash="$(nix-prefetch-url --type sha256 --unpack "file://${tmp}")"
  rm -f "$tmp"
  to_sri "$hash"
}

# Update the first occurrence of `attr = "...";` in a Nix file.
replace_string_attr() {
  local file="$1" attr="$2" value="$3"
  local line
  line="$(grep -n "^[[:space:]]*${attr} = \"" "$file" | head -1 | cut -d: -f1)"
  if [[ -z "$line" ]]; then
    echo "ERROR: could not find attribute '$attr' in $file" >&2
    return 1
  fi
  sed -i "${line}s|${attr} = \"[^\"]*\";|${attr} = \"$value\";|" "$file"
}

# Extracts the Go version from a go.mod line like "go 1.26.4".
parse_go_mod_version() {
  local content="$1"
  local go_version
  go_version="$(printf '%s\n' "$content" | grep -E '^go[[:space:]]+[0-9]+\.[0-9]+' | head -1 | awk '{print $2}')"
  if [[ -z "$go_version" ]]; then
    echo "ERROR: could not parse Go version from go.mod" >&2
    return 1
  fi
  printf '%s\n' "$go_version"
}

update_crush() {
  echo "=== crush ==="
  local file="$PKGS_DIR/crush.nix"
  local tag
  tag="$(retry 3 gh release list --repo charmbracelet/crush --limit 2 --json tagName -q '.[1].tagName')"
  local version="${tag#v}"
  local hash
  hash="$(prefetch_github_sri charmbracelet crush "$tag")"

  replace_string_attr "$file" version "$version"
  replace_string_attr "$file" hash "$hash"
  replace_string_attr "$file" vendorHash "$PLACEHOLDER_HASH"

  # Crush may require a specific Go version not in nixpkgs; warn if go.mod changed.
  local go_mod_content crush_go_version
  go_mod_content="$(retry 3 gh api "repos/charmbracelet/crush/contents/go.mod?ref=${tag}" --jq '.content' | base64 -d)"
  crush_go_version="$(parse_go_mod_version "$go_mod_content")"
  if [[ -n "$crush_go_version" ]]; then
    local current_go_version
    current_go_version="$(grep -E '^[[:space:]]*version = "' "$PKGS_DIR/go_1_26_7.nix" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')"
    if [[ "$crush_go_version" != "$current_go_version" ]]; then
      echo "crush ${version} requires Go ${crush_go_version}; current pinned Go is ${current_go_version}."
      echo "Run './scripts/update.sh go' to update the pinned Go package if needed."
    fi
  fi

  echo "Updated crush to $version. Run a build to get the new vendorHash, then update the file."
}

update_bunnylol() {
  echo "=== bunnylol ==="
  local file="$PKGS_DIR/bunnylol.nix"
  local commit
  commit="$(retry 3 gh api repos/facebook/bunnylol.rs/commits/main --jq '.sha')"
  local hash
  hash="$(prefetch_github_sri facebook bunnylol.rs "$commit")"

  replace_string_attr "$file" rev "$commit"
  replace_string_attr "$file" hash "$hash"
  replace_string_attr "$file" cargoHash "$PLACEHOLDER_HASH"
  echo "Updated bunnylol to $commit. Build to get the new cargoHash."
}

update_wshowkeys() {
  echo "=== wshowkeys ==="
  local file="$PKGS_DIR/wshowkeys.nix"
  local commit
  commit="$(retry 3 gh api repos/DreamMaoMao/wshowkeys/commits/main --jq '.sha')"
  local hash
  hash="$(prefetch_github_sri DreamMaoMao wshowkeys "$commit")"

  replace_string_attr "$file" rev "$commit"
  replace_string_attr "$file" hash "$hash"
  echo "Updated wshowkeys to $commit."
}

update_kisesi() {
  echo "=== kisesi ==="
  local file="$PKGS_DIR/kisesi.nix"
  local tag
  tag="$(retry 3 gh api repos/eeriemyxi/kisesi/tags --jq '.[0].name')"
  local version="${tag#v}"
  local hash
  hash="$(prefetch_github_sri eeriemyxi kisesi "$tag")"

  replace_string_attr "$file" version "$version"
  replace_string_attr "$file" sha256 "$hash"
  echo "Updated kisesi to $tag."
}

update_mechvibes_lite() {
  echo "=== mechvibes-lite ==="
  local file="$PKGS_DIR/mechvibes-lite.nix"
  local tag
  tag="$(retry 3 gh api repos/eeriemyxi/mechvibes-lite/tags --jq '.[0].name')"
  local version="${tag#v}"
  local hash
  hash="$(prefetch_github_sri eeriemyxi mechvibes-lite "$tag")"

  replace_string_attr "$file" version "$version"
  replace_string_attr "$file" sha256 "$hash"
  echo "Updated mechvibes-lite to $tag."
}

update_claude_code() {
  echo "=== claude-code ==="
  local base_url="https://downloads.claude.ai/claude-code-releases"
  local version
  version="$(curl -fsSL "$base_url/latest")"
  curl -fsSL "$base_url/$version/manifest.json" --output "$PKGS_DIR/claude-manifest.json"
  echo "Updated claude-code manifest to version $version."
  # No per-platform hashes are stored in the .nix file; they are read from the JSON at eval time.
}

update_go() {
  echo "=== go ==="
  local file="$PKGS_DIR/go_1_26_7.nix"
  local latest
  latest="$(curl -fsSL 'https://go.dev/dl/?mode=json' | nix run nixpkgs#jq -- -r '.[].version' | grep '^go1.26' | sort -V | tail -1)"
  local version="${latest#go}"
  replace_string_attr "$file" version "$version"

  # Only the linux-amd64 hash is stored; replace the first hash in the hashes attrset.
  local hash
  hash="$(prefetch_url_sri "https://go.dev/dl/go${version}.linux-amd64.tar.gz")"
  local line
  line="$(grep -n "linux-amd64 = \"" "$file" | head -1 | cut -d: -f1)"
  if [[ -z "$line" ]]; then
    echo "ERROR: could not find linux-amd64 hash in $file" >&2
    return 1
  fi
  sed -i "${line}s|sha256-[^\"]*=|$hash|" "$file"
  echo "Updated go to $version."
}

update_iaito() {
  echo "=== iaito ==="
  local file="$PKGS_DIR/iaito.nix"
  local tag
  tag="$(retry 3 gh release list --repo radareorg/iaito --limit 1 --json tagName -q '.[0].tagName')"
  local version="${tag#v}"
  local main_rev
  main_rev="$(retry 3 gh api "repos/radareorg/iaito/git/ref/tags/${tag}" --jq '.object.sha')"
  local trans_default_branch
  trans_default_branch="$(retry 3 gh api repos/radareorg/iaito-translations --jq '.default_branch')"
  local trans_rev
  trans_rev="$(retry 3 gh api "repos/radareorg/iaito-translations/commits/${trans_default_branch}" --jq '.sha')"
  local main_hash trans_hash
  main_hash="$(prefetch_github_sri radareorg iaito "$main_rev")"
  trans_hash="$(prefetch_github_sri radareorg iaito-translations "$trans_rev")"

  replace_string_attr "$file" version "$version"
  # Replace the first fetchFromGitHub's rev and hash (main source).
  local main_rev_line
  main_rev_line="$(grep -n "owner = \"radareorg\";" "$file" | head -1 | cut -d: -f1)"
  if [[ -z "$main_rev_line" ]]; then
    echo "ERROR: could not find main owner block in $file" >&2
    return 1
  fi
  sed -i "${main_rev_line},/^      }/{s|rev = \"[^\"]*\";|rev = \"$main_rev\";|; s|hash = \"[^\"]*\";|hash = \"$main_hash\";|}" "$file"
  # Replace the second fetchFromGitHub's rev and hash (translations source).
  local trans_rev_line
  trans_rev_line="$(grep -n "repo = \"iaito-translations\";" "$file" | head -1 | cut -d: -f1)"
  if [[ -z "$trans_rev_line" ]]; then
    echo "ERROR: could not find translations repo line in $file" >&2
    return 1
  fi
  sed -i "${trans_rev_line},/^      }/{s|rev = \"[^\"]*\";|rev = \"$trans_rev\";|; s|hash = \"[^\"]*\";|hash = \"$trans_hash\";|}" "$file"
  echo "Updated iaito to $version (main=$main_rev, translations=$trans_rev)."
}

# Latest commit SHA on a repo's default branch (branch name is queried,
# since it is not always "main").
github_head_commit() {
  local owner="$1" repo="$2"
  local branch
  branch="$(retry 3 gh api "repos/${owner}/${repo}" --jq '.default_branch')"
  retry 3 gh api "repos/${owner}/${repo}/commits/${branch}" --jq '.sha'
}

# Update rev and hash of the fetchFromGitHub block containing `repo = "<repo>";`.
update_github_rev_hash() {
  local file="$1" repo="$2" rev="$3" hash="$4"
  local anchor
  anchor="$(grep -Fn "repo = \"${repo}\";" "$file" | head -1 | cut -d: -f1)"
  if [[ -z "$anchor" ]]; then
    echo "ERROR: could not find repo '$repo' in $file" >&2
    return 1
  fi
  sed -i "${anchor},/^  };/{s|rev = \"[^\"]*\";|rev = \"$rev\";|; s|hash = \"[^\"]*\";|hash = \"$hash\";|}" "$file"
}

update_yazi_plugins() {
  echo "=== yazi-plugins ==="
  local file="$PKGS_DIR/default.nix"
  local yazi_rev ouch_rev gvfs_rev
  yazi_rev="$(github_head_commit yazi-rs plugins)"
  ouch_rev="$(github_head_commit ndtoan96 ouch.yazi)"
  gvfs_rev="$(github_head_commit boydaihungst gvfs.yazi)"
  local yazi_hash ouch_hash gvfs_hash
  yazi_hash="$(prefetch_github_sri yazi-rs plugins "$yazi_rev")"
  ouch_hash="$(prefetch_github_sri ndtoan96 ouch.yazi "$ouch_rev")"
  gvfs_hash="$(prefetch_github_sri boydaihungst gvfs.yazi "$gvfs_rev")"

  update_github_rev_hash "$file" "plugins" "$yazi_rev" "$yazi_hash"
  update_github_rev_hash "$file" "ouch.yazi" "$ouch_rev" "$ouch_hash"
  update_github_rev_hash "$file" "gvfs.yazi" "$gvfs_rev" "$gvfs_hash"
  echo "Updated yazi-plugins to $yazi_rev, ouch.yazi to $ouch_rev, gvfs.yazi to $gvfs_rev."
  echo "Tip: run 'nix flake update yazi' to keep the yazi binary in lockstep with these plugins."
}

main() {
  if [[ $# -eq 0 ]]; then
    update_crush
    update_bunnylol
    update_wshowkeys
    update_kisesi
    update_mechvibes_lite
    update_claude_code
    update_iaito
    update_yazi_plugins
  else
    for pkg in "$@"; do
      case "$pkg" in
        crush) update_crush ;;
        bunnylol) update_bunnylol ;;
        wshowkeys) update_wshowkeys ;;
        kisesi) update_kisesi ;;
        mechvibes-lite) update_mechvibes_lite ;;
        claude-code) update_claude_code ;;
        go) update_go ;;
        iaito) update_iaito ;;
        yazi-plugins) update_yazi_plugins ;;
        *) echo "Unknown package: $pkg" >&2; exit 1 ;;
      esac
    done
  fi
}

main "$@"
