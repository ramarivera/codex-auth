#!/usr/bin/env bash
# One-time publish script for @ramarivera/codex-auth packages
# After this, you configure trusted publishers on npmjs.com and the GitHub Actions workflow
# takes over for all future releases.
#
# Prerequisites:
#   1. Create a granular npm access token at https://www.npmjs.com/settings/ramarivera/tokens
#   2. Set it as NPM_TOKEN environment variable: export NPM_TOKEN=npm_xxxx
#   3. Run this script

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)"

echo "=== Building binaries ==="
cd "$REPO_ROOT"
mise exec zig -- zig build -Doptimize=ReleaseSafe

echo ""
echo "=== Staging npm packages ==="
node scripts/npm/stage-packages.mjs --artifacts-dir zig-out --output-dir dist/npm

echo ""
echo "=== Publishing packages ==="

# Check token
if [ -z "${NPM_TOKEN:-}" ]; then
    echo "ERROR: Set NPM_TOKEN environment variable first"
    echo "  export NPM_TOKEN=npm_xxxxxxxx"
    exit 1
fi

# Configure npm for this shell
npm config set //registry.npmjs.org/:_authToken "$NPM_TOKEN"

PACKAGES=(
    "dist/npm/codex-auth-linux-x64"
    "dist/npm/codex-auth-linux-arm64"
    "dist/npm/codex-auth-darwin-x64"
    "dist/npm/codex-auth-darwin-arm64"
    "dist/npm/codex-auth-win32-x64"
    "dist/npm/codex-auth-win32-arm64"
    "dist/npm/root"
)

for pkg in "${PACKAGES[@]}"; do
    pkg_name=$(node -p "require('$REPO_ROOT/$pkg/package.json').name")
    pkg_version=$(node -p "require('$REPO_ROOT/$pkg/package.json').version")
    echo "Publishing $pkg_name@$pkg_version..."
    npm publish "$pkg" --access public
    echo "  OK"
done

echo ""
echo "=== All packages published ==="
echo ""
echo "Next steps:"
echo "1. Go to npmjs.com and configure trusted publishers for each of these 7 packages:"
echo "   - @ramarivera/codex-auth"
echo "   - @ramarivera/codex-auth-linux-x64"
echo "   - @ramarivera/codex-auth-linux-arm64"
echo "   - @ramarivera/codex-auth-darwin-x64"
echo "   - @ramarivera/codex-auth-darwin-arm64"
echo "   - @ramarivera/codex-auth-win32-x64"
echo "   - @ramarivera/codex-auth-win32-arm64"
echo ""
echo "   For each: Package Settings → Trusted Publisher → GitHub Actions"
echo "   Owner: ramarivera, Repo: codex-auth, Workflow: release.yml"
echo ""
echo "2. Revoke the temporary NPM token on npmjs.com"
echo ""
echo "3. Push a tag to test the GitHub Actions workflow:"
echo "   git tag v0.2.10-silent.1"
echo "   git push origin v0.2.10-silent.1"
echo ""
echo "   The workflow will build, test, and publish via trusted publishing."
echo ""
echo "4. Verify the workflow succeeded and the packages show up on npm with provenance badges."
