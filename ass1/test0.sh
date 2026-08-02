#!/bin/dash
# testing subset 0 svc-init


mkdir -p "TEST_DIR"
cd "TEST_DIR"


failed_init=0
failed=0



echo "\nsvc-init structure verification test..\n"

../svc-init >/dev/null

echo "\nTESTING SVC-INIT...\n"
if [ ! -d ".svc" ]; then
    echo "FAIL: .svc directory was not properly created" >&2
    failed=$(expr $failed + 1)
fi

if [ ! -d ".svc/.reference" ]; then
    echo "FAIL: .svc/.reference/ directory was not properly created" >&2
    failed=$(expr $failed + 1)
fi

if [ ! -d ".svc/.reference/logs" ]; then
    echo "FAIL: .svc/.reference/logs/ directory was not properly created" >&2
    failed=$(expr $failed + 1)
fi

if [ ! -d ".svc/.reference/objects" ]; then
    echo "FAIL: .svc/.reference/objects/ directory was not properly created" >&2
    failed=$(expr $failed + 1)
fi

if [ ! -d ".svc/.reference/refs" ]; then
    echo "FAIL: .svc/.reference/refs/ was not properly created" >&2
    failed=$(expr $failed + 1)
fi

if [ ! -f ".svc/.reference/index" ]; then
    echo "FAIL: .svc/.reference/index was not properly created" >&2
    failed=$(expr $failed + 1)
fi

echo "\nVerifying that calling svc-init fails when repo already exists\n"

second_init=$(../svc-init 2>&1)

if [ "$second_init" = "svc-init: error: .svc already exists\n" ]; then
    echo "FAIL: Incorrect error message displayed when initializing duplicate repo"
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

