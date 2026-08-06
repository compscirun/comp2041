#!/bin/bash

PASSED=0
FAILED=0


check_result() {
    local test_name="$1"
    if diff -q expected.txt actual.txt >/dev/null 2>&1; then
        echo -e "\033[1;32mPassed $test_name\033[0m"
        ((PASSED++))
    else
        echo -e "\033[1;31mFailed $test_name\033[0m"
        echo -e "\033[1;32mExpected Output:\033[0m"
        cat expected.txt
        echo -e "\033[1;31mActual Output:\033[0m"
        cat actual.txt
        ((FAILED++))
    fi

}

echo "testing subset 0"
echo "========================================"

echo "testing sedlite quit command"
echo ""

cat << 'EOF' > expected.txt
1
2
3
4
5
EOF
seq 1 10 | python3 -s -S sedlite.py '5q' > actual.txt 2>&1
check_result "basic test (address) - 5q"


echo "testing print command"
echo ""


cat << 'EOF' > expected.txt
20
21
22
22
23
24
25
26
27
28
29
30
EOF
seq 20 30 | python3 -s -S sedlite.py '3p' > actual.txt 2>&1
check_result "basic test - 3p"


echo "testing sed address parsing"
echo ""


cat << 'EOF' > expected.txt
20
21
22
EOF
seq 20 30 | python3 -s -S sedlite.py '3q' > actual.txt 2>&1
check_result "Basic single address validity check - 3q"


cat << 'EOF' > expected.txt
sedlite: command line: invalid command
EOF
seq 20 30 | python3 -s -S sedlite.py '%p' > actual.txt 2>&1
check_result "Basic invalid address - %p"


cat << 'EOF' > expected.txt
20
21
21
22
22
23
23
24
25
26
27
28
29
30
EOF
seq 20 30 | python3 -s -S sedlite.py '2,4p' > actual.txt 2>&1
check_result "Basic dual address validity check - 2,4p"


cat << 'EOF' > expected.txt
30
EOF
seq 20 30 | python3 -s -S sedlite.py -n '$p' > actual.txt 2>&1
check_result "Basic end address validity check - \$p"


cat << 'EOF' > expected.txt
15
16
17
18
19
20
EOF
seq 15 25 | python3 -s -S sedlite.py '/2./q' > actual.txt 2>&1
check_result "Regex address check - /2./q"


cat << 'EOF' > expected.txt
6000
6001
6002
6003
6004
6005
6006
6007
EOF
seq 6000 7000 | python3 -s -S sedlite.py '/^6.+7/q' > actual.txt 2>&1
check_result "Regex address check 2 - /^6.+7/q"

rm -f expected.txt actual.txt


echo -e "\033[1mTEST SUMMARY: \033[0m"
echo -ne "\033[1;32m$PASSED Test(s) Passed \033[0m"
echo -e "\033[1;31m $FAILED Test(s) Failed \033[0m"


if [ "$FAILED" -gt 0 ]; then
    exit 1
else
    exit 0
fi