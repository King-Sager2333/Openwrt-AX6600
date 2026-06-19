#!/bin/bash

set -e

# Extract function from Scripts/Settings.sh
eval "$(awk '/^apply_sed_to_matches\(\) \{/{flag=1} flag; /^\}/{flag=0; print ""; exit}' Scripts/Settings.sh)"

# Setup test directory and files
TEST_DIR=$(mktemp -d)

# Test 1: Happy path
TEST_FILE="test_file.txt"
TEST_PATH="$TEST_DIR/$TEST_FILE"
echo "Hello World" > "$TEST_PATH"

apply_sed_to_matches "$TEST_DIR" "$TEST_FILE" "s/World/Universe/g"

RESULT=$(cat "$TEST_PATH")
if [ "$RESULT" != "Hello Universe" ]; then
    echo "Test 1 failed. Expected 'Hello Universe', got '$RESULT'."
    rm -rf "$TEST_DIR"
    exit 1
fi
echo "Test 1 passed."

# Test 2: No match
# Should not fail
apply_sed_to_matches "$TEST_DIR" "non_existent.txt" "s/World/Universe/g"
echo "Test 2 passed."

# Test 3: Multiple files
TEST_FILE2="test_file.txt"
TEST_DIR2="$TEST_DIR/subdir"
mkdir -p "$TEST_DIR2"
TEST_PATH2="$TEST_DIR2/$TEST_FILE2"
echo "Hello World 2" > "$TEST_PATH2"
echo "Hello World 3" > "$TEST_PATH"

apply_sed_to_matches "$TEST_DIR" "$TEST_FILE" "s/World/Galaxy/g"

RESULT=$(cat "$TEST_PATH")
if [ "$RESULT" != "Hello Galaxy 3" ]; then
    echo "Test 3 failed (file 1). Expected 'Hello Galaxy 3', got '$RESULT'."
    rm -rf "$TEST_DIR"
    exit 1
fi
RESULT2=$(cat "$TEST_PATH2")
if [ "$RESULT2" != "Hello Galaxy 2" ]; then
    echo "Test 3 failed (file 2). Expected 'Hello Galaxy 2', got '$RESULT2'."
    rm -rf "$TEST_DIR"
    exit 1
fi
echo "Test 3 passed."

# Test 4: Spaces in filename
TEST_FILE4="test file with spaces.txt"
TEST_PATH4="$TEST_DIR/$TEST_FILE4"
echo "Hello Space" > "$TEST_PATH4"

apply_sed_to_matches "$TEST_DIR" "$TEST_FILE4" "s/Space/Void/g"

RESULT4=$(cat "$TEST_PATH4")
if [ "$RESULT4" != "Hello Void" ]; then
    echo "Test 4 failed. Expected 'Hello Void', got '$RESULT4'."
    rm -rf "$TEST_DIR"
    exit 1
fi
echo "Test 4 passed."

# Cleanup
rm -rf "$TEST_DIR"
echo "All tests passed."
exit 0
