#!/bin/dash
# testing subset 1 svc-rm

mkdir -p "TEST_DIR"
cd "TEST_DIR"

failed=0

../svc-init >/dev/null 

echo "\nTESTING SVC-RM...\n"

echo "\n Test 1: No repository error"
stdout=$(../svc-rm a 2>&1)
if [ "$stdout" != "svc-rm: error: svc repository directory .svc not found" ]; then
    echo "  FAIL: Did not print correct no-repo error. Got: $stdout" >&2 
    failed=$(expr $failed + 1)
fi

echo "\n Test 2: Missing file from index"
stdout=$(../svc-rm a 2>&1)
if [ "$stdout" != "svc-rm: error: 'a' is not in the svc repository" ]; then
    echo "  FAIL: Did not reject unversioned file. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi

touch a b c
../svc-add a b c
../svc-commit -m "initial commit" >/dev/null 

echo "\n Test 3: Standard remove"
../svc-rm a
if [ -f a ] || grep -qF "file|a|" ".svc/.reference/index"; then
    echo "  FAIL: File 'a' was not removed from workspace or index" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 4: Cached remove"
../svc-rm --cached b
if [ ! -f b ]; then
    echo "  FAIL: File 'b' was removed from workspace despite --cached flag" >&2
    failed=$(expr $failed + 1)
fi
if grep -qF "file|b|" ".svc/.reference/index"; then
    echo "  FAIL: File 'b' was not removed from index" >&2
    failed=$(expr $failed + 1)
fi

echo "\n Test 5: Modified file remove error"
echo "modified" > c
stdout=$(../svc-rm c 2>&1)
if [ "$stdout" != "svc-rm: error: 'c' in the repository is different to the working file" ]; then
    echo "  FAIL: Did not reject modified file properly. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi


echo "\n Test 6: --force flag removes unstaged file in index"

touch d 
../svc-add d
../svc-rm 
stdout=$(../svc-rm c 2>&1)
if ! echo "$stdout" | grep -q "'c' in index is different to both the working file and the repository"; then
    echo "  FAIL: Did not reject modified file properly. Got: $stdout" >&2
    failed=$(expr $failed + 1)
fi



cd ..
rm -rf "TEST_DIR"

if [ "$failed" -eq 0 ]; then
    echo "SUCCESS: svc-rm passed all directory structure and error checks."
    exit 0
else
    echo "FAILURE: $failed check(s) failed." >&2
    exit 1
fi