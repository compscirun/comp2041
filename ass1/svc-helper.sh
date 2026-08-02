#!/bin/dash

# Hasher

hash_object() {
    FILE="$1"

    HASH=$(sha256sum "$FILE" | cut -d' ' -f1)
    echo "$HASH"
}

compare_hash() {
    FILE1="$1"
    FILE2="$2"
    HASH1=$(hash_object "$FILE1")
    HASH2=$(hash_object "$FILE2")
    if [ "$HASH1" = "$HASH2" ]; then
        echo 0
    else
        echo 1
    fi
}

# Filename checker for svc-add
check_filename() {
    FILENAME=$1
    
    if echo "$FILENAME" | grep -qE '^[a-zA-Z0-9][a-zA-Z0-9._-]*$'; then 
        echo 1
    else
        echo 0
    fi
}

check_in_index() {
    INDEX_FILE=$1
    filename=$2
    if [ -f "$INDEX_FILE" ] && grep -qF "file|$filename|" "$INDEX_FILE"; then
        echo 1
    else
        echo 0
    fi
}