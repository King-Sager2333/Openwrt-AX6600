#!/bin/bash

# Ensure script stops on first error
set -e

# Load the target script
source "${BASH_SOURCE%/*}/../Scripts/Packages.sh"

# Global variables for mocks
CURL_CALLED=0
JQ_CALLED=0
SHA256SUM_CALLED=0
DPKG_CALLED=0

# Mock for curl
curl() {
    CURL_CALLED=$((CURL_CALLED + 1))
    local url=""
    for arg in "$@"; do
        if [[ "$arg" == http* ]]; then
            url="$arg"
            break
        fi
    done

    if [[ "$url" == *"api.github.com/repos/test/package/releases"* ]]; then
        echo '[{"prerelease": false, "tag_name": "v2.0.0"}]'
    elif [[ "$url" == *"api.github.com/repos/test/uptodate/releases"* ]]; then
        echo '[{"prerelease": false, "tag_name": "v1.0.0"}]'
    elif [[ "$url" == *"test/package/releases/download/v2.0.0/test-package-2.0.0.tar.gz"* ]]; then
        echo "dummy package content for v2.0.0"
    elif [[ "$url" == *"test/package/archive/v2.0.0.tar.gz"* ]]; then
        echo "dummy archive content for v2.0.0"
    elif [[ "$url" == *"test/uptodate/releases/download/v1.0.0/test-package-1.0.0.tar.gz"* ]]; then
        echo "dummy package content for v1.0.0"
    else
        echo "Mock curl: unknown URL: $url" >&2
        return 1
    fi
}

# Mock for jq
jq() {
    JQ_CALLED=$((JQ_CALLED + 1))
    local argjson_mark=""

    # We only care about jq being used as it is in UPDATE_VERSION
    # jq -r --argjson mark "$PKG_MARK" 'map(select(.prerelease == $mark)) | first | .tag_name'

    # Read from stdin
    local input=$(cat)
    if [[ "$input" == *'"tag_name": "v2.0.0"'* ]]; then
        echo "v2.0.0"
    elif [[ "$input" == *'"tag_name": "v1.0.0"'* ]]; then
        echo "v1.0.0"
    else
        echo "unknown_tag"
    fi
}

# Mock for sha256sum
sha256sum() {
    SHA256SUM_CALLED=$((SHA256SUM_CALLED + 1))
    # Read from stdin
    local input=$(cat)
    if [[ "$input" == "dummy package content for v2.0.0" ]]; then
        echo "new_hash_2.0.0  -"
    elif [[ "$input" == "dummy archive content for v2.0.0" ]]; then
        echo "new_hash_archive_2.0.0  -"
    else
        echo "unknown_hash  -"
    fi
}

# Mock for dpkg
dpkg() {
    if [[ "$1" == "--compare-versions" ]]; then
        DPKG_CALLED=$((DPKG_CALLED + 1))
        local ver1="$2"
        local op="$3"
        local ver2="$4"
        if [[ "$op" == "lt" ]]; then
            # Simple lexicographical comparison for our test cases
            # Extract numbers only for simplicity, or just use string comparison
            ver1="${ver1#v}"
            ver2="${ver2#v}"
            if [[ "$ver1" < "$ver2" ]]; then
                return 0
            else
                return 1
            fi
        fi
    fi
    # Real dpkg fallback
    command dpkg "$@"
}

echo "Mocks loaded successfully."

# Setup Test Environment
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

echo "Created test directory at $TEST_DIR"

cd "$TEST_DIR"
mkdir -p package/test-package
mkdir -p package/test-uptodate

# Create mock Makefiles
cat << 'EOF' > package/test-package/Makefile
PKG_NAME:=test-package
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/test/package/releases/download/v1.0.0
PKG_SOURCE:=test-package-1.0.0.tar.gz
PKG_HASH:=old_hash_1.0.0

include $(INCLUDE_DIR)/package.mk
EOF

cat << 'EOF' > package/test-uptodate/Makefile
PKG_NAME:=test-uptodate
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/test/uptodate/releases/download/v1.0.0
PKG_SOURCE:=test-package-1.0.0.tar.gz
PKG_HASH:=old_hash_1.0.0

include $(INCLUDE_DIR)/package.mk
EOF

# Assert function
assert_eq() {
    local expected="$1"
    local actual="$2"
    local msg="$3"
    if [[ "$expected" != "$actual" ]]; then
        echo "FAIL: $msg"
        echo "Expected: $expected"
        echo "Actual:   $actual"
        exit 1
    else
        echo "PASS: $msg"
    fi
}

echo "=== Running Tests ==="

# Test 1: Package not found
echo "Test 1: Package not found"
OUTPUT=$(UPDATE_VERSION "non-existent-package" 2>&1 | grep -v "find: ")
assert_eq "non-existent-package not found!" "$OUTPUT" "Should print not found message and return"

# Reset mock counters
CURL_CALLED=0
SHA256SUM_CALLED=0

# Test 2: Successful update of an outdated package
echo "Test 2: Update outdated package"
mkdir -p ../feeds/packages/ 2>/dev/null || true
UPDATE_VERSION "test-package"
NEW_VER_MAKEFILE=$(grep "PKG_VERSION:=" package/test-package/Makefile | cut -d'=' -f2)
NEW_HASH_MAKEFILE=$(grep "PKG_HASH:=" package/test-package/Makefile | cut -d'=' -f2)

assert_eq "2.0.0" "$NEW_VER_MAKEFILE" "Makefile PKG_VERSION should be updated"
assert_eq "new_hash_2.0.0" "$NEW_HASH_MAKEFILE" "Makefile PKG_HASH should be updated"

# Reset mock counters
CURL_CALLED=0
SHA256SUM_CALLED=0

# Test 3: Package already up to date
echo "Test 3: Package up to date"
OUTPUT=$(UPDATE_VERSION "test-uptodate" 2>&1)
NEW_VER_MAKEFILE=$(grep "PKG_VERSION:=" package/test-uptodate/Makefile | cut -d'=' -f2)

assert_eq "1.0.0" "$NEW_VER_MAKEFILE" "Makefile PKG_VERSION should remain the same"
if [[ "$OUTPUT" != *"test-uptodate/Makefile version is already the latest!"* ]]; then
    echo "FAIL: Should print 'already the latest!' message"
    echo "Actual output: $OUTPUT"
    exit 1
else
    echo "PASS: Should print 'already the latest!' message"
fi

echo "=== All Tests Passed ==="
