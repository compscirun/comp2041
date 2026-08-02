#!/bin/dash
# testing subset 0 svc-commit

mkdir -p "TEST_DIR"
cd "TEST_DIR"

failed=0

../svc-init >/dev/null 

echo "\nTESTING SVC-COMMIT...\n"

echo "\n Test 1: Invalid message"

stdout=$(../svc-commit 2>&1)
if [ "$stdout" != "usage: svc-commit [-a] -m commit-message" ]; then
    echo "  FAIL: Did not print proper usage error. Got: $stdout" >&2 
    failed=$(expr $failed + 1)
fi

echo "\n Test 2: Valid Commit"
stdout=$(../svc-commit -m "first commit" 2>&1)
if [ "$stdout" != "Committed as commit 0" ]; then
    echo "  FAIL: Commit 0 output mismatch. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 3: Commit with no changes"
stdout=$(../svc-commit -m "empty commit" 2>&1)
if [ "$stdout" != "nothing to commit" ]; then
    echo "  FAIL: Commit 0 output mismatch. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 4: Multiple commits"

echo "line 1" > a
../svc-add a

stdout=$(../svc-commit -m "second commit" 2>&1)
if [ "$stdout" != "Committed as commit 1" ]; then
    echo "  FAIL: Commit 1 output mismatch. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

echo "line 1" > b
../svc-add b

stdout=$(../svc-commit -m "third commit" 2>&1)
if [ "$stdout" != "Committed as commit 2" ]; then
    echo "  FAIL: Commit 2 output mismatch. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 5: Check commit only updates repo with staged changes"

echo "Version 1" > file.txt
../svc-add file.txt

echo "Version 2" > file.txt
../svc-commit -m "Committing version 1" >/dev/null

stdout=$(../svc-show 0:file.txt 2>&1)
if [ "$stdout" != "Version 1" ]; then
    echo "  FAIL: Commit captured workspace changes. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

stdout=$(../svc-show :file.txt 2>&1)
if [ "$stdout" != "Version 1" ]; then
    echo "  FAIL: Index was overwritten by workspace changes. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi





cd ..
rm -rf "TEST_DIR"

if [ "$failed" -eq 0 ]; then
    echo "SUCCESS: svc-init passed all directory structure and error checks."
    exit 0
else
    echo "FAILURE: $failed check(s) failed." >&2
    exit 1
fi





