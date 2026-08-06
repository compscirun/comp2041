#!/usr/bin/env python3

import sys
import argparse
import fileinput


from sedliteParser import SedliteParser

class SedContext:
    def __init__(self):
        self.curr_line = ""
        self.curr_index = 0
        self.is_deleted = False
        self.has_quit = False
        self.is_last_line = False

def main():


    argparser = argparse.ArgumentParser()

    argparser.add_argument("-n", action="store_true", help="Enable no printing")
    argparser.add_argument("-f", action="store_true", help="sed command filename")
    argparser.add_argument("commands", help="sed command script")
    argparser.add_argument("input_files", nargs="*", type=str, help="Input file (defaults to stdin)")
    args = argparser.parse_args()

    no_print = args.n
    commands_from_file=args.f

    if args.f:
        with open(args.commands) as f:
                raw_commands = f.read()
    else:
        raw_commands = args.commands
    
    parser = SedliteParser(raw_commands)
    commands = parser.parse()
    
    
    context = SedContext()
    files_to_read = args.input_files if args.input_files else ['-']

    iterator = iter(enumerate(fileinput.input(files=files_to_read), start=1))

    try:
        prev_index, prev_line = next(iterator)
        has_next = True
    except StopIteration:
        has_next = False


    while has_next:
        try:
            next_index, next_line = next(iterator)
            is_last = False
        except StopIteration:
            is_last = True

        context.curr_index = prev_index
        context.curr_line = prev_line
        context.is_last_line = is_last
        context.is_deleted = False
        context.has_quit = False
        for command in commands:
            command.execute(context)
            if context.is_deleted or context.has_quit:
                break

        if not context.is_deleted and not no_print:
            print(context.curr_line, end="")
        
        if context.has_quit:
            break

        if not is_last:
            prev_index, prev_line = next_index, next_line
        else:
            has_next = False

if __name__ == "__main__":
    main()