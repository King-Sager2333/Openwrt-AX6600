#!/bin/bash

# --- Test Framework ---
pass_count=0
fail_count=0

assert_exists() {
    if [ -e "$1" ]; then
        echo "✅ PASS: $1 exists"
        ((pass_count++))
    else
        echo "❌ FAIL: $1 does not exist"
        ((fail_count++))
    fi
}

assert_not_exists() {
    if [ ! -e "$1" ]; then
        echo "✅ PASS: $1 does not exist"
        ((pass_count++))
    else
        echo "❌ FAIL: $1 exists"
        ((fail_count++))
    fi
}

# --- Setup ---
# Create a temporary directory for testing
TEST_DIR=$(mktemp -d)
ORIG_DIR=$(pwd)

# Mock git command
git() {
    echo "[MOCK GIT] $@"
    if [[ "$1" == "clone" ]]; then
        local url="${@: -1}"
        local repo_name=$(basename -s .git "$url")
        mkdir -p "$repo_name"

        # In test 3 we test 'pkg' where it expects a certain directory structure
        if [[ "$url" == *"TestPkgPkg"* ]]; then
            mkdir -p "$repo_name/some_dir/my-target-pkg"
            touch "$repo_name/some_dir/my-target-pkg/Makefile"
        fi
    fi
}
export -f git

# Source the script we want to test
source "$ORIG_DIR/Scripts/Packages.sh"

cd "$TEST_DIR"

# Ensure feeds directory structure exists to mock the environment
mkdir -p feeds/luci
mkdir -p feeds/packages/oaf_dir
mkdir -p feeds/packages/luci-app-appfilter

# Move into a mocked build directory
mkdir -p build_dir
cd build_dir

# --- Test 1: Basic clone and removal of old directories ---
echo "--- Test 1: Basic clone and cleanup ---"
mkdir -p ../feeds/luci/open-app-filter
mkdir -p ../feeds/packages/oaf
mkdir -p ../feeds/packages/luci-app-appfilter
mkdir -p ../feeds/packages/other-pkg

UPDATE_PACKAGE "open-app-filter" "destan19/OpenAppFilter" "master" "" "luci-app-appfilter oaf"

assert_not_exists "../feeds/luci/open-app-filter"
assert_not_exists "../feeds/packages/oaf"
assert_not_exists "../feeds/packages/luci-app-appfilter"
assert_exists "../feeds/packages/other-pkg"
assert_exists "OpenAppFilter"

# --- Test 2: 'name' special case ---
echo "--- Test 2: 'name' special handling ---"
UPDATE_PACKAGE "renamed-pkg" "test/TestPkg" "master" "name" ""

assert_exists "renamed-pkg"
assert_not_exists "TestPkg"

# --- Test 3: 'pkg' special case ---
echo "--- Test 3: 'pkg' special handling ---"
UPDATE_PACKAGE "my-target-pkg" "test/TestPkgPkg" "master" "pkg" ""

assert_exists "my-target-pkg"
assert_not_exists "TestPkgPkg"

# --- Teardown ---
cd "$ORIG_DIR"
rm -rf "$TEST_DIR"

echo "Passed: $pass_count, Failed: $fail_count"
if [ "$fail_count" -gt 0 ]; then
    echo "Exiting with error"
    exit 1
fi
