# sedlite: A Lightweight Stream Editor

## Overview
`sedlite` is a streamlined, Python-based implementation of the classic Unix utility `sed` (stream editor). It provides a core subset of `sed` functionality, allowing users to perform basic text transformations on an input stream (a file or input from a pipeline) [cite: 1]. 

## Command Line Usage
The basic syntax for invoking `sedlite` is as follows:
```bash
python3 sedlite.py [-n] [-f script-file] [script] [file...]
```

### Options
*   `-n`: **No printing.** Suppresses the default behavior of automatically printing the pattern space (current line) at the end of each cycle [cite: 1].
*   `-f <file>`: **Script file.** Reads `sed` commands from the specified file instead of taking them from the command line argument [cite: 1].
*   `script`: The `sed` commands to execute (if `-f` is not provided) [cite: 1].
*   `file...`: Input files to process. If none are specified, `sedlite` reads from standard input (`stdin`) [cite: 1].

## Addressing
By default, `sedlite` applies its commands to every line of the input. However, you can restrict commands to specific lines using addresses [cite: 2]. `sedlite` supports both single addresses and comma-separated address ranges [cite: 3].

Supported address formats include:
*   `number`: Matches exactly the line specified by the line `number` (1-indexed) [cite: 2].
*   `$`: Matches the last line of the last input file [cite: 2].
*   `/regexp/`: Matches any line containing a substring that matches the regular expression `regexp` [cite: 2].

**Address Ranges:**
Two addresses separated by a comma (e.g., `1,5` or `/start/,/end/`) specify a range of lines. The command will be applied starting from the line matching the first address and continuing until a line matches the second address (inclusive) [cite: 2].

## Supported Commands
`sedlite` parses commands separated by semicolons (`;`), commas (`,`), or newlines (`
`) [cite: 3]. It ignores comments prefixed by the `#` character [cite: 3].

### 1. Substitute (`s`)
The substitute command replaces text matching a regular expression pattern with a replacement string [cite: 2].
**Syntax:** `[address]s/pattern/replacement/[flags]`
*   `pattern`: The regular expression to search for [cite: 3].
*   `replacement`: The string to replace the matched pattern [cite: 3].
*   `flags`: `sedlite` supports the `g` (global) flag, which replaces all occurrences of the pattern in the line. Without the `g` flag, only the first occurrence is replaced [cite: 2].

### 2. Print (`p`)
The print command explicitly prints the current line [cite: 2]. This is most often used in conjunction with the `-n` command-line option to only print lines that match a specific address or condition.
**Syntax:** `[address]p`

### 3. Delete (`d`)
The delete command marks the current line as deleted, preventing it from being printed (even if `-n` is not set) and immediately stopping the processing of any remaining commands for that cycle [cite: 1, 2].
**Syntax:** `[address]d`

### 4. Quit (`q`)
The quit command instructs `sedlite` to immediately exit without reading any further input lines or executing any further commands [cite: 1]. Note that `q` does not accept an address range (two addresses); it only takes a single address [cite: 3].
**Syntax:** `[address]q`

## Architecture & Implementation Details
*   **Context (`SedContext`):** Tracks the current execution state, including the current line content, line index, deletion status, quit flags, and end-of-file conditions [cite: 1].
*   **Parser (`SedliteParser`):** A custom tokenizer that iterates over the script character by character, handling escapes and separating complex address ranges and `s` command components [cite: 3].
*   **Commands System:** Designed with an Object-Oriented approach using the `Command` abstract base class. This base class manages address matching and range tracking (`in_range`), leaving individual command execution logic to concrete subclasses (`SubstituteCommand`, `DeleteCommand`, `PrintCommand`, `QuitCommand`) [cite: 2].