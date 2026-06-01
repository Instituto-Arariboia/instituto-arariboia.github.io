#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-4000}"
BUNDLE_PATH="${BUNDLE_PATH:-vendor/bundle}"
BUILD_ONLY=0
NO_INSTALL=0
LIVERELOAD=1

usage() {
  cat <<'USAGE'
Usage: scripts/test-site.sh [options]

Build and serve the Instituto Arariboia Jekyll site locally.

Options:
  --build-only       Build the site and exit without starting a server.
  --host HOST        Host for the local server. Default: 127.0.0.1
  --port PORT        Port for the local server. Default: 4000
  --no-install       Do not run bundle install; fail if gems are missing.
  --no-livereload    Start the server without livereload.
  -h, --help         Show this help.

Examples:
  scripts/test-site.sh
  scripts/test-site.sh --build-only
  scripts/test-site.sh --host 0.0.0.0 --port 4001
USAGE
}

permission_hint() {
  cat <<HINT

This script should be run as your normal user, not with sudo.

If a previous sudo run created root-owned files, fix the workspace with:

  sudo chown -R "$(id -u):$(id -g)" "$ROOT_DIR/Gemfile.lock" "$ROOT_DIR/_site" "$ROOT_DIR/.bundle" "$ROOT_DIR/vendor" 2>/dev/null || true

Then run:

  scripts/test-site.sh

HINT
}

native_gem_hint() {
  cat <<'HINT'

Ruby gem installation failed. On Ubuntu/Debian, install the native build
dependencies and run this script again:

  sudo apt update
  sudo apt install -y ruby-full ruby-dev build-essential zlib1g-dev

HINT
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-only)
      BUILD_ONLY=1
      shift
      ;;
    --host)
      HOST="${2:-}"
      if [[ -z "$HOST" ]]; then
        echo "Missing value for --host" >&2
        exit 2
      fi
      shift 2
      ;;
    --port)
      PORT="${2:-}"
      if [[ -z "$PORT" ]]; then
        echo "Missing value for --port" >&2
        exit 2
      fi
      shift 2
      ;;
    --no-install)
      NO_INSTALL=1
      shift
      ;;
    --no-livereload)
      LIVERELOAD=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "${EUID:-$(id -u)}" -eq 0 && "${ALLOW_ROOT:-0}" != "1" ]]; then
  echo "Refusing to run as root because it can create root-owned build files." >&2
  permission_hint
  exit 1
fi

blocking_paths=()
for path in Gemfile.lock _site .bundle vendor; do
  if [[ -e "$path" && ! -w "$path" ]]; then
    blocking_paths+=("$path")
  fi
done

if [[ "${#blocking_paths[@]}" -gt 0 ]]; then
  echo "Some generated dependency/build paths are not writable:" >&2
  printf '  %s\n' "${blocking_paths[@]}" >&2
  permission_hint
  exit 1
fi

if ! command -v ruby >/dev/null 2>&1; then
  echo "Ruby is required but was not found." >&2
  native_gem_hint
  exit 1
fi

if ! command -v gem >/dev/null 2>&1; then
  echo "RubyGems is required but was not found." >&2
  native_gem_hint
  exit 1
fi

if ! command -v bundle >/dev/null 2>&1; then
  echo "Bundler is not installed. Installing bundler for the current user..."
  if ! gem install --user-install bundler; then
    native_gem_hint
    exit 1
  fi

  USER_GEM_BIN="$(ruby -e 'print Gem.user_dir')/bin"
  export PATH="$USER_GEM_BIN:$PATH"
fi

if [[ ! -f Gemfile ]]; then
  echo "Gemfile not found in $ROOT_DIR" >&2
  exit 1
fi

bundle config set path "$BUNDLE_PATH" >/dev/null

if ! bundle check >/dev/null 2>&1; then
  if [[ "$NO_INSTALL" -eq 1 ]]; then
    echo "Bundle dependencies are missing. Run without --no-install to install them." >&2
    exit 1
  fi

  echo "Installing Ruby dependencies..."
  if ! bundle install; then
    native_gem_hint
    exit 1
  fi
fi

echo "Building site..."
bundle exec jekyll build --trace

if [[ "$BUILD_ONLY" -eq 1 ]]; then
  echo "Build complete: $ROOT_DIR/_site"
  exit 0
fi

serve_args=(serve --host "$HOST" --port "$PORT")
if [[ "$LIVERELOAD" -eq 1 ]]; then
  serve_args+=(--livereload)
fi

echo "Serving site at http://$HOST:$PORT/"
echo "Publications: http://$HOST:$PORT/publicacoes/"
exec bundle exec jekyll "${serve_args[@]}"
