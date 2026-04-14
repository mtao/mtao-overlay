#!/usr/bin/env bash
set -euo pipefail

# check-releases.sh — Show latest GitHub Releases for overlay packages
#                      and optionally create ebuilds for new releases.
#
# Usage: ./scripts/check-releases.sh [-n N] [-c config] [-u]
#   -n N       Default number of releases to show per package (default: 2)
#   -c FILE    Path to config file (default: scripts/check-releases.conf)
#   -u         Update mode: create ebuilds for NEW releases and regenerate Manifests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DEFAULT_COUNT=2
CONFIG_FILE="$SCRIPT_DIR/check-releases.conf"
UPDATE=false

while getopts "n:c:uh" opt; do
    case "$opt" in
        n) DEFAULT_COUNT="$OPTARG" ;;
        c) CONFIG_FILE="$OPTARG" ;;
        u) UPDATE=true ;;
        h)
            echo "Usage: $0 [-n N] [-c config] [-u]"
            echo "  -n N       Default number of releases per package (default: 2)"
            echo "  -c FILE    Config file (default: scripts/check-releases.conf)"
            echo "  -u         Update: create ebuilds for new releases and run 'ebuild manifest'"
            exit 0
            ;;
        *) exit 1 ;;
    esac
done

# Verify dependencies
for cmd in gh jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is not installed." >&2
        exit 1
    fi
done

if ! gh auth status &>/dev/null; then
    echo "Error: 'gh' is not authenticated. Run 'gh auth login' first." >&2
    exit 1
fi

if $UPDATE && ! command -v ebuild &>/dev/null; then
    echo "Error: 'ebuild' is not available. Is Portage installed?" >&2
    exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

# Strip common version prefixes from a release tag to compare with ebuild versions.
# Add new prefix patterns here as needed.
strip_tag_prefix() {
    local tag="$1"
    tag="${tag#v}"
    tag="${tag#bun-v}"
    echo "$tag"
}

# Find the latest non-9999 ebuild in a package directory.
# Returns the full path, or empty string if none found.
find_template_ebuild() {
    local pkg_dir="$1"
    local package="$2"
    local latest=""
    for ebuild in "$pkg_dir"/*.ebuild; do
        [[ -f "$ebuild" ]] || continue
        local fname
        fname="$(basename "$ebuild" .ebuild)"
        local ver="${fname#"${package}-"}"
        # Skip live ebuilds
        [[ "$ver" == "9999" ]] && continue
        latest="$ebuild"
    done
    echo "$latest"
}

# Read config and process each package
while IFS= read -r line; do
    # Skip comments and blank lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// /}" ]] && continue

    # Parse fields
    read -r pkg_atom gh_repo pkg_count <<< "$line"
    count="${pkg_count:-$DEFAULT_COUNT}"

    # Extract category/package components
    category="${pkg_atom%/*}"
    package="${pkg_atom#*/}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$pkg_atom ($gh_repo)"

    # Find current ebuild versions
    pkg_dir="$OVERLAY_DIR/$category/$package"
    versions=()
    if [[ -d "$pkg_dir" ]]; then
        for ebuild in "$pkg_dir"/*.ebuild; do
            [[ -f "$ebuild" ]] || continue
            fname="$(basename "$ebuild" .ebuild)"
            ver="${fname#"${package}-"}"
            versions+=("$ver")
        done
        if (( ${#versions[@]} > 0 )); then
            ver_str="${versions[0]}"
            for v in "${versions[@]:1}"; do
                ver_str+=", $v"
            done
            echo "  Ebuild versions: $ver_str"
        else
            echo "  Ebuild versions: (none)"
        fi
    else
        echo "  Ebuild versions: (package dir not found)"
    fi

    # Fetch releases from GitHub as JSON
    echo "  Latest releases:"
    release_json=$(gh release list --repo "$gh_repo" --limit "$count" \
        --json tagName,publishedAt,isDraft,isPrerelease,isLatest 2>/dev/null) || true

    num_releases=$(echo "$release_json" | jq 'length' 2>/dev/null) || num_releases=0

    if [[ "$num_releases" -eq 0 ]]; then
        echo "    (no GitHub Releases found)"
        echo
        continue
    fi

    # Collect new versions for update mode
    new_versions=()

    for (( i = 0; i < num_releases; i++ )); do
        tag=$(echo "$release_json" | jq -r ".[$i].tagName")
        date=$(echo "$release_json" | jq -r ".[$i].publishedAt" | cut -dT -f1)
        is_draft=$(echo "$release_json" | jq -r ".[$i].isDraft")
        is_prerelease=$(echo "$release_json" | jq -r ".[$i].isPrerelease")
        is_latest=$(echo "$release_json" | jq -r ".[$i].isLatest")

        # Build status label
        label=""
        if [[ "$is_draft" == "true" ]]; then
            label="Draft"
        elif [[ "$is_prerelease" == "true" ]]; then
            label="Pre-release"
        elif [[ "$is_latest" == "true" ]]; then
            label="Latest"
        fi

        # Check if this release tag matches an existing ebuild version
        stripped="$(strip_tag_prefix "$tag")"
        has_ebuild=false
        for ver in "${versions[@]+"${versions[@]}"}"; do
            if [[ "$ver" == "$stripped" ]]; then
                has_ebuild=true
                break
            fi
        done

        marker=""
        if ! $has_ebuild; then
            marker=" [NEW]"
            # Only queue non-draft, non-prerelease versions for update
            if [[ "$is_draft" != "true" && "$is_prerelease" != "true" ]]; then
                new_versions+=("$stripped")
            fi
        fi

        if [[ -n "$label" ]]; then
            printf "    %-30s  %-12s  [%s]%s\n" "$tag" "$date" "$label" "$marker"
        else
            printf "    %-30s  %-12s%s\n" "$tag" "$date" "$marker"
        fi
    done

    # Update mode: create ebuilds for new versions
    if $UPDATE && (( ${#new_versions[@]} > 0 )); then
        template="$(find_template_ebuild "$pkg_dir" "$package")"
        if [[ -z "$template" ]]; then
            echo "  !! No non-9999 ebuild to use as template, skipping update"
        else
            echo "  Updating:"
            template_name="$(basename "$template")"
            for new_ver in "${new_versions[@]}"; do
                new_ebuild="$pkg_dir/${package}-${new_ver}.ebuild"
                if [[ -f "$new_ebuild" ]]; then
                    echo "    $package-$new_ver.ebuild already exists, skipping"
                    continue
                fi
                cp "$template" "$new_ebuild"
                echo "    Created ${package}-${new_ver}.ebuild (from $template_name)"
            done
            # Regenerate Manifest for the whole package (covers all ebuilds)
            # Use the newest ebuild to drive the manifest command
            newest_ebuild="$pkg_dir/${package}-${new_versions[0]}.ebuild"
            echo "    Running: ebuild $newest_ebuild manifest"
            if ebuild "$newest_ebuild" manifest 2>&1 | sed 's/^/    /'; then
                echo "    Manifest updated"
            else
                echo "    !! Manifest generation failed"
            fi
        fi
    fi

    echo
done < "$CONFIG_FILE"
