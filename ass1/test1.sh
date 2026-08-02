#!/bin/dash
# testing subset 0 svc-add


mkdir -p "TEST_DIR"
cd "TEST_DIR"

failed=0

../svc-init >/dev/null 

stdout=$(../svc-add doesnt_exist 2>&1)

echo "\nTESTING SVC-ADD...\n"

echo "\n Test 1: missing file"
if [ "$stdout" != "svc-add: error: can not open 'doesnt_exist'" ]; then
    echo "  FAIL: Did not reject missing file" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 2: Bad file name"
stdout=$(../svc-add bad@name 2>&1)
if [ "$stdout" != "svc-add: error: invalid filename bad@name" ]; then
    echo "  FAIL: Did not properly reject invalid filename" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 3: Testing successful add"

touch a b
../svc-add a b

if [ ! -f ".svc/.reference/index" ]; then
    echo "  FAIL: Index file not created after add" >&2
    failed=$(expr $failed + 1)
fi

if ! grep -F "file|a|" ".svc/.reference/index" || ! grep -F "file|b|" ".svc/.reference/index"
    echo "  FAIL: Files not properly indexed after add" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 4: Testing file removed from index if removed from workspace and then added"

touch c
../svc-add c
rm c
stdout=$(../svc-add c 2>&1)
if [ "$stdout" != "" ]; then
    echo "  FAIL: Invalid message thrown for valid instruction. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

if grep -F "file|c|" ".svc/.reference/index"; then
    echo "  FAIL: File not taken down after removed and then added" >&2
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






