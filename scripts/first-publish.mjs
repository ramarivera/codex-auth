#!/usr/bin/env node
/**
 * One-time publish script for @ramarivera/codex-auth packages.
 *
 * After this, you configure trusted publishers on npmjs.com and the GitHub Actions
 * workflow takes over for all future releases.
 *
 * Prerequisites:
 *   1. Create a granular npm access token at https://www.npmjs.com/settings/ramarivera/tokens
 *   2. Set it: $env.NPM_TOKEN = "npm_xxxxxxxx"
 *   3. Run: node scripts/first-publish.mjs
 */

import { execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, "..");

const npmToken = process.env.NPM_TOKEN;

if (!npmToken) {
  console.error("ERROR: Set NPM_TOKEN environment variable first");
  console.error("  Nushell: $env.NPM_TOKEN = \"npm_xxxxxxxx\"");
  console.error("  bash:   export NPM_TOKEN=npm_xxxxxxxx");
  console.error("  PowerShell: $env:NPM_TOKEN = 'npm_xxxxxxxx'");
  process.exit(1);
}

function run(cmd, opts = {}) {
  const cwd = opts.cwd ?? repoRoot;
  console.log(`  > ${cmd}`);
  return execSync(cmd, { cwd, stdio: "inherit", ...opts });
}

console.log("=== Building binaries ===");
run("mise exec zig -- zig build -Doptimize=ReleaseSafe");

console.log("\n=== Staging npm packages ===");
run("node scripts/npm/stage-packages.mjs --artifacts-dir zig-out --output-dir dist/npm");

console.log("\n=== Publishing packages ===");

// Configure npm auth for this process
const npmrcPath = path.join(repoRoot, ".npmrc");
const npmrcContent = `//registry.npmjs.org/:_authToken=${npmToken}\n`;
fs.writeFileSync(npmrcPath, npmrcContent, { encoding: "utf8" });

const packages = [
  "dist/npm/codex-auth-linux-x64",
  "dist/npm/codex-auth-linux-arm64",
  "dist/npm/codex-auth-darwin-x64",
  "dist/npm/codex-auth-darwin-arm64",
  "dist/npm/codex-auth-win32-x64",
  "dist/npm/codex-auth-win32-arm64",
  "dist/npm/root",
];

for (const pkg of packages) {
  const pkgPath = path.join(repoRoot, pkg, "package.json");
  const { name, version } = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
  console.log(`\nPublishing ${name}@${version}...`);
  run(`npm publish ${pkg} --access public`);
}

// Clean up
fs.unlinkSync(npmrcPath);
console.log("\n=== All packages published ===");
console.log("\nNext steps:");
console.log("1. Go to npmjs.com and configure trusted publishers for these 7 packages:");
console.log("   - @ramarivera/codex-auth (root)");
console.log("   - @ramarivera/codex-auth-linux-x64");
console.log("   - @ramarivera/codex-auth-linux-arm64");
console.log("   - @ramarivera/codex-auth-darwin-x64");
console.log("   - @ramarivera/codex-auth-darwin-arm64");
console.log("   - @ramarivera/codex-auth-win32-x64");
console.log("   - @ramarivera/codex-auth-win32-arm64");
console.log("");
console.log("   For each: Package → Settings → Trusted Publisher → GitHub Actions");
console.log("   Owner: ramarivera, Repo: codex-auth, Workflow: release.yml");
console.log("");
console.log("2. Revoke the temporary NPM token on npmjs.com");
console.log("");
console.log("3. Push a tag to test the GitHub Actions workflow:");
console.log("   git tag v0.2.10-silent.1");
console.log("   git push origin v0.2.10-silent.1");
console.log("");
console.log("   The workflow will build, test, and publish via trusted publishing.");
console.log("");
console.log("4. Verify the workflow succeeded and the packages show provenance badges.");
