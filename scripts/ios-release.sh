#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTION="${1:-}"

PROJECT_PATH="${IOS_PROJECT_PATH:-AbsoluteTimer.xcodeproj}"
SCHEME="${IOS_SCHEME:-AbsoluteTimer}"
CONFIGURATION="${IOS_CONFIGURATION:-Release}"
DESTINATION="${IOS_DESTINATION:-generic/platform=iOS}"
DERIVED_DATA_PATH="${IOS_DERIVED_DATA_PATH:-$ROOT_DIR/build/DerivedData}"
ARCHIVE_PATH="${IOS_ARCHIVE_PATH:-$ROOT_DIR/build/ios-release/AbsoluteTimer.xcarchive}"
EXPORT_PATH="${IOS_EXPORT_PATH:-$ROOT_DIR/build/ios-release/export}"
EXPORT_OPTIONS_PLIST="${IOS_EXPORT_OPTIONS_PLIST:-$ROOT_DIR/scripts/ExportOptions-AppStore.plist}"
BUNDLE_ID="${APPLE_BUNDLE_ID:-}"
TEAM_ID="${APPLE_DEVELOPMENT_TEAM:-${AT_IOS_TEAM_ID:-}}"
ASC_KEY_ID="${APPLE_APP_STORE_CONNECT_KEY_ID:-}"
ASC_ISSUER_ID="${APPLE_APP_STORE_CONNECT_ISSUER_ID:-}"
ASC_PRIVATE_KEY_PATH="${APPLE_APP_STORE_CONNECT_PRIVATE_KEY_PATH:-}"
AUTH_ARGS=()
SIGNING_ARGS=()

usage() {
  cat <<'USAGE'
Usage:
  npm run build
  npm run package
  npm run ios:archive
  npm run ios:upload
  npm run release

Actions:
  build     Compile the Release iOS app for a generic iOS device without signing.
  archive   Increment the iOS build number, then build a Release .xcarchive in build/ios-release.
  upload    Upload the existing archive to App Store Connect.
  release   Increment the iOS build number, archive, then upload the archive to App Store Connect.

Required for upload:
  APPLE_APP_STORE_CONNECT_KEY_ID
  APPLE_APP_STORE_CONNECT_ISSUER_ID
  APPLE_APP_STORE_CONNECT_PRIVATE_KEY_PATH

Recommended for signing:
  APPLE_DEVELOPMENT_TEAM

Optional overrides:
  IOS_PROJECT_PATH
  IOS_SCHEME
  IOS_CONFIGURATION
  IOS_DESTINATION
  IOS_DERIVED_DATA_PATH
  IOS_ARCHIVE_PATH
  IOS_EXPORT_PATH
  IOS_EXPORT_OPTIONS_PLIST
USAGE
}

read_dotenv_value() {
  node -e '
    const fs = require("node:fs");
    const key = process.argv[1];
    const envPath = process.argv[2];

    if (!fs.existsSync(envPath)) {
      process.exit(0);
    }

    const lines = fs.readFileSync(envPath, "utf8").split(/\r?\n/);
    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith("#")) {
        continue;
      }

      const match = trimmed.match(/^(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$/);
      if (!match || match[1] !== key) {
        continue;
      }

      let value = match[2].trim();
      if (
        (value.startsWith("\"") && value.endsWith("\"")) ||
        (value.startsWith("'") && value.endsWith("'"))
      ) {
        value = value.slice(1, -1);
      } else {
        value = value.replace(/\s+#.*$/, "");
      }

      process.stdout.write(value);
      process.exit(0);
    }
  ' "$1" "$ROOT_DIR/.env"
}

read_project_setting() {
  node -e '
    const fs = require("node:fs");
    const projectFile = process.argv[1];
    const setting = process.argv[2];

    if (!fs.existsSync(projectFile)) {
      process.exit(0);
    }

    const content = fs.readFileSync(projectFile, "utf8");
    const pattern = new RegExp(`${setting}\\s*=\\s*([^;]+);`);
    const match = content.match(pattern);
    if (!match) {
      process.exit(0);
    }

    process.stdout.write(match[1].trim().replace(/^"|"$/g, ""));
  ' "$1" "$2"
}

load_dotenv_fallbacks() {
  local project_file
  project_file="$(resolve_xcode_project_file)"

  if [[ -z "$BUNDLE_ID" ]]; then
    BUNDLE_ID="$(read_dotenv_value APPLE_BUNDLE_ID)"
    if [[ -z "$BUNDLE_ID" ]]; then
      BUNDLE_ID="$(read_project_setting "$project_file" PRODUCT_BUNDLE_IDENTIFIER)"
    fi
    if [[ -z "$BUNDLE_ID" ]]; then
      BUNDLE_ID="com.discomedia.AbsoluteTimer"
    fi
  fi

  if [[ -z "$TEAM_ID" ]]; then
    TEAM_ID="$(read_dotenv_value APPLE_DEVELOPMENT_TEAM)"
    if [[ -z "$TEAM_ID" ]]; then
      TEAM_ID="$(read_dotenv_value AT_IOS_TEAM_ID)"
    fi
    if [[ -z "$TEAM_ID" ]]; then
      TEAM_ID="$(read_project_setting "$project_file" DEVELOPMENT_TEAM)"
    fi
  fi

  if [[ -z "$ASC_KEY_ID" ]]; then
    ASC_KEY_ID="$(read_dotenv_value APPLE_APP_STORE_CONNECT_KEY_ID)"
  fi

  if [[ -z "$ASC_ISSUER_ID" ]]; then
    ASC_ISSUER_ID="$(read_dotenv_value APPLE_APP_STORE_CONNECT_ISSUER_ID)"
  fi

  if [[ -z "$ASC_PRIVATE_KEY_PATH" ]]; then
    ASC_PRIVATE_KEY_PATH="$(read_dotenv_value APPLE_APP_STORE_CONNECT_PRIVATE_KEY_PATH)"
  fi
}

resolve_path() {
  local path_value="$1"
  if [[ "$path_value" = /* ]]; then
    printf "%s" "$path_value"
  else
    printf "%s/%s" "$ROOT_DIR" "$path_value"
  fi
}

resolve_xcode_project_file() {
  local project_path
  project_path="$(resolve_path "$PROJECT_PATH")"

  if [[ "$project_path" != *.xcodeproj ]]; then
    echo "Automatic iOS build-number bump requires IOS_PROJECT_PATH to point to a .xcodeproj." >&2
    echo "Current IOS_PROJECT_PATH resolves to $project_path." >&2
    exit 1
  fi

  local project_file="$project_path/project.pbxproj"
  if [[ ! -f "$project_file" ]]; then
    echo "Could not find Xcode project file at $project_file." >&2
    exit 1
  fi

  printf "%s" "$project_file"
}

bump_ios_build_number() {
  local project_file
  project_file="$(resolve_xcode_project_file)"

  node -e '
    const fs = require("node:fs");
    const projectFile = process.argv[1];
    const content = fs.readFileSync(projectFile, "utf8");
    const matches = [...content.matchAll(/CURRENT_PROJECT_VERSION\s*=\s*([^;]+);/g)];

    if (matches.length === 0) {
      console.error(`No CURRENT_PROJECT_VERSION entries found in ${projectFile}.`);
      process.exit(1);
    }

    const versions = matches.map((match) => match[1].trim().replace(/^"|"$/g, ""));
    const nonIntegerVersions = versions.filter((version) => !/^\d+$/.test(version));

    if (nonIntegerVersions.length > 0) {
      console.error(`Cannot auto-increment non-integer iOS build number(s): ${[...new Set(nonIntegerVersions)].join(", ")}.`);
      console.error("Set CURRENT_PROJECT_VERSION to an integer before archiving.");
      process.exit(1);
    }

    const currentBuildNumber = Math.max(...versions.map((version) => Number.parseInt(version, 10)));
    const nextBuildNumber = currentBuildNumber + 1;
    const updated = content.replace(
      /CURRENT_PROJECT_VERSION\s*=\s*([^;]+);/g,
      `CURRENT_PROJECT_VERSION = ${nextBuildNumber};`
    );

    fs.writeFileSync(projectFile, updated);

    const previousValues = [...new Set(versions)].sort((a, b) => Number.parseInt(a, 10) - Number.parseInt(b, 10));
    console.log(`Bumped iOS build number from ${previousValues.join(", ")} to ${nextBuildNumber}.`);
  ' "$project_file"
}

build_command_args() {
  AUTH_ARGS=()
  SIGNING_ARGS=()

  if [[ -n "$ASC_KEY_ID" && -n "$ASC_ISSUER_ID" && -n "$ASC_PRIVATE_KEY_PATH" ]]; then
    AUTH_ARGS=(
      "-authenticationKeyPath" "$(resolve_path "$ASC_PRIVATE_KEY_PATH")" \
      "-authenticationKeyID" "$ASC_KEY_ID" \
      "-authenticationKeyIssuerID" "$ASC_ISSUER_ID"
    )
  fi

  if [[ -n "$TEAM_ID" ]]; then
    SIGNING_ARGS=("DEVELOPMENT_TEAM=$TEAM_ID")
  fi
}

require_upload_credentials() {
  if [[ -z "$ASC_KEY_ID" || -z "$ASC_ISSUER_ID" || -z "$ASC_PRIVATE_KEY_PATH" ]]; then
    echo "Upload requires App Store Connect API key values in .env or your shell:" >&2
    echo "  APPLE_APP_STORE_CONNECT_KEY_ID" >&2
    echo "  APPLE_APP_STORE_CONNECT_ISSUER_ID" >&2
    echo "  APPLE_APP_STORE_CONNECT_PRIVATE_KEY_PATH" >&2
    exit 1
  fi

  local private_key_path
  private_key_path="$(resolve_path "$ASC_PRIVATE_KEY_PATH")"
  if [[ ! -f "$private_key_path" ]]; then
    echo "Could not find App Store Connect private key at $private_key_path." >&2
    exit 1
  fi
}

explain_upload_failure() {
  local latest_log_bundle
  latest_log_bundle="$(
    find "${TMPDIR:-/tmp}" -maxdepth 1 -type d -name "${SCHEME}_*.xcdistributionlogs" -print 2>/dev/null |
      sort |
      tail -1
  )"

  if [[ -z "$latest_log_bundle" ]]; then
    return
  fi

  if grep -R "DistributionAppRecordProviderError.missingApp" "$latest_log_bundle" >/dev/null 2>&1; then
    echo "" >&2
    echo "App Store Connect rejected the upload before packaging because it cannot find an app record for this bundle ID." >&2
    echo "Create an App Store Connect app for bundle ID $BUNDLE_ID, or confirm this API key has access to that app." >&2
    echo "Xcode distribution logs: $latest_log_bundle" >&2
    return
  fi

  echo "" >&2
  echo "Xcode distribution logs: $latest_log_bundle" >&2
}

build_app() {
  echo "Building $SCHEME ($CONFIGURATION) for $DESTINATION ..."
  build_command_args

  xcodebuild build \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    ${AUTH_ARGS[@]+"${AUTH_ARGS[@]}"} \
    ${SIGNING_ARGS[@]+"${SIGNING_ARGS[@]}"}
}

archive_app() {
  mkdir -p "$(dirname "$ARCHIVE_PATH")"
  bump_ios_build_number

  echo "Archiving $SCHEME ($CONFIGURATION) to $ARCHIVE_PATH ..."
  build_command_args

  xcodebuild archive \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    ${AUTH_ARGS[@]+"${AUTH_ARGS[@]}"} \
    ${SIGNING_ARGS[@]+"${SIGNING_ARGS[@]}"}
}

upload_archive() {
  require_upload_credentials

  if [[ ! -d "$ARCHIVE_PATH" ]]; then
    echo "Archive not found at $ARCHIVE_PATH." >&2
    echo "Run npm run ios:archive first, or run npm run release." >&2
    exit 1
  fi

  if [[ ! -f "$EXPORT_OPTIONS_PLIST" ]]; then
    echo "Export options plist not found at $EXPORT_OPTIONS_PLIST." >&2
    exit 1
  fi

  mkdir -p "$EXPORT_PATH"

  echo "Uploading $ARCHIVE_PATH to App Store Connect ..."
  build_command_args

  set +e
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
    -allowProvisioningUpdates \
    ${AUTH_ARGS[@]+"${AUTH_ARGS[@]}"} \
    ${SIGNING_ARGS[@]+"${SIGNING_ARGS[@]}"}
  local export_status=$?
  set -e

  if [[ "$export_status" -ne 0 ]]; then
    explain_upload_failure
    exit "$export_status"
  fi
}

cd "$ROOT_DIR"
load_dotenv_fallbacks

case "$ACTION" in
  build)
    build_app
    ;;
  archive|package)
    archive_app
    ;;
  upload)
    upload_archive
    ;;
  release)
    archive_app
    upload_archive
    ;;
  ""|help|--help|-h)
    usage
    ;;
  *)
    echo "Unknown iOS release action: $ACTION" >&2
    usage >&2
    exit 1
    ;;
esac
