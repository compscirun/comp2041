#!/usr/bin/env python3

import sys
import re

def main():

    search_word = sys.argv[1]
    content = sys.stdin.read()

    pattern = rf"\b{re.escape(search_word)}\b"
    
    words = len(re.findall(pattern, content, re.IGNORECASE))

    print(f"{search_word} occurred {words} times")

if __name__ == "__main__":
    main()
