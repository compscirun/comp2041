#!/usr/bin/env python3

import sys
import re
import glob
import numpy as np

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

def log_prob( search_word ):

    data = {}

    for file in glob.glob("lyrics/*.txt"):
        
        total_wordcount = total_words(file)
        num_words = word_count(search_word, file)
        clean_text = re.sub(r"^lyrics/|\.txt$", "", file)
        artist = re.sub(r"_+", " ", clean_text).strip()

        frequency = (num_words + 1) / total_wordcount
        log_freq = np.log(frequency)
        data[artist] = log_freq
    
    sorted_data = dict(sorted(data.items()))

    return sorted_data

def main():
    
    data = {}

    for arg in sys.argv[1:]:
        
        log_probs = log_prob(arg)
        for key, value in log_probs.items():
            data[key] = data.get(key, 0) + value

    for artist, log_frequency in data.items():
        print(f"{log_frequency:10.5f} {artist}")
if __name__ == "__main__":
    main()