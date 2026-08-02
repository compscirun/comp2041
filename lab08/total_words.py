#!/usr/bin/env python3
import sys
import re

def main():

    content = sys.stdin.read().strip()

    words = len(re.findall(r'[a-zA-Z]+', content))

    print(f"{ words } words")

if __name__ == "__main__":
    main()