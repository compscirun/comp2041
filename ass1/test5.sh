#!/bin/dash
# testing subset 1 svc-show

mkdir -p "TEST_DIR"
cd "TEST_DIR"

failed=0

../svc-init >/dev/null 

echo "\nTESTING SVC-SHOW...\n"

echo "\n Test 1: File not in index"
stdout=$(../svc-show :missing 2>&1)
if [ "$stdout" != "svc-show: error: 'missing' not found in index" ]; then
    echo "  FAIL: Wrong error for missing file in index. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

echo "version 1" > a
../svc-add a
../svc-commit -m "first commit"

echo "\n Test 2: Unknown commit error"
stdout=$(../svc-show 99:a 2>&1)
if [ "$stdout" != "svc-show: error: unknown commit '99'" ]; then
    echo "  FAIL: Wrong error for unknown commit. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 3: File not in commit error"
stdout=$(../svc-show 0:b 2>&1)
if [ "$stdout" != "svc-show: error: 'b' not found in commit 0" ]; then
    echo "  FAIL: Wrong error for file missing from commit. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 4: Show from index"
echo "version 2" > a
../svc-add a
stdout=$(../svc-show :a 2>&1)
if [ "$stdout" != "version 2" ]; then
    echo "  FAIL: Failed to show correctly from index. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 5: Show from commit"
stdout=$(../svc-show 0:a 2>&1)
if [ "$stdout" != "version 1" ]; then
    echo "  FAIL: Failed to show correctly from commit 0. Got: $stdout" >&2
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