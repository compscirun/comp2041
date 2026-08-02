#!/bin/dash
# testing subset 1: svc-show

mkdir -p "TEST_DIR"
cd "TEST_DIR"

failed=0

echo "\nTESTING SVC-SHOW...\n"

../svc-init > /dev/null

# 1st commit
echo "1" > a

../svc-add a
../svc-commit -m "First commit" > /dev/null

# 2nd commit
echo "2" > a
../svc-add a
../svc-commit -m "Second commit" > /dev/null

# staged changes
echo "3" > a
../svc-add a

# workspace changes
echo "4" > a


echo "\n Test 1: Show changes from commit 0"
stdout=$(../svc-show 0:a 2>&1)
if [ "$stdout" != "1" ]; then
    echo "  FAIL: Failed to retrieve the correct version from commit 0. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi


echo "\n Test 2: Show changes from commit 1"
stdout=$(../svc-show 1:a 2>&1)
if [ "$stdout" != "2" ]; then
    echo "  FAIL: Failed to retrieve the correct version from commit 1. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 3: Show staged changes"
stdout=$(../svc-show :a 2>&1)
if [ "$stdout" != "3" ]; then
    echo "  FAIL: Failed to accurately retrieve the staged version from the index. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 4: Error handling - Unknown commit"
stdout=$(../svc-show 99:a 2>&1)
if [ "$stdout" != "svc-show: error: unknown commit '99'" ]; then
    echo "  FAIL: Did not output the correct error for an unknown commit. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi


echo "\n Test 5: Error handling - Requesting file not present in commit"
echo "heyo" > b
../svc-add b
../svc-commit -m "Third commit" > /dev/null

stdout=$(../svc-show 0:b 2>&1)
if [ "$stdout" != "svc-show: error: 'b' not found in commit 0" ]; then
    echo "  FAIL: Did not output the correct error for a missing file in a valid commit. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi


cd ..
rm -rf "TEST_DIR"

if [ "$failed" -eq 0 ]; then
    echo "SUCCESS: svc-show passed all checks."
    exit 0
else
    echo "FAILURE: $failed check(s) failed." >&2
    exit 1
fi