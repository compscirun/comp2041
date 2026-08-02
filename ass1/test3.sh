#!/bin/dash
# testing subset 1 svc-log

mkdir -p "TEST_DIR"
cd "TEST_DIR"

failed=0

../svc-init >/dev/null 

echo "\nTESTING SVC-LOG...\n"

echo "\n Test 1: Empty log behavior"
stdout=$(../svc-log 2>&1)
if [ "$stdout" != "" ]; then
    echo "  FAIL: Log should return no commits. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

echo "line 1" > a
../svc-add a
../svc-commit -m "first commit" > /dev/null

echo "line 2" > b
../svc-add b
../svc-commit -m "second commit" > /dev/null

echo "\n Test 2: Standard log output and order"
expected=$(printf "1 second commit\n0 first commit")
stdout=$(../svc-log 2>&1)

if [ "$stdout" != "$expected" ]; then
    echo "  FAIL: Log output or order mismatch. Got:\n$stdout\nExpected:\n$expected" >&2
    failed=$(expr $failed + 1)
fi

cd ..
rm -rf "TEST_DIR"

if [ "$failed" -eq 0 ]; then
    echo "SUCCESS: svc-log passed all checks."
    exit 0
else
    echo "FAILURE: $failed check(s) failed." >&2
    exit 1
fi