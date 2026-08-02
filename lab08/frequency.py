#!/usr/bin/env python3
import sys
import re
import glob
import math
def word_count( search_word, filename ):

    with open(filename) as f:
        content = f.read().strip()

    pattern = rf"\b{re.escape(search_word)}\b"
    
    num_words = len(re.findall(pattern, content, re.IGNORECASE))

    return num_words

def total_words ( filename ) :

    with open(filename) as f:
        content = f.read().strip()

    num_words = len(re.findall(r'[a-zA-Z]+', content))

    return num_words

def main():

    data = {}

    search_word = sys.argv[1]

    for file in glob.glob("lyrics/*.txt"):
        
        total_wordcount = total_words(file)
        num_words = word_count(search_word, file)
        

        clean_text = re.sub(r"^lyrics/|\.txt$", "", file)
        artist = re.sub(r"_+", " ", clean_text).strip()

        frequency = num_words / total_wordcount

        details = { "total" : total_wordcount , "num_words" : num_words, "frequency" : frequency }

        data[artist] = details
    
    sorted_data = dict(sorted(data.items()))

    for artist, details in sorted_data.items():
        print(f"{details['num_words']:4}/{details['total']:6} = {details['frequency']:.9f} {artist}")


if __name__ == "__main__":
    main()