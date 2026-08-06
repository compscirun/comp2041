#!/usr/bin/env python3

import sys
from typing import Optional, Dict, List, Any
from sedliteCommands import Command, SubstituteCommand, QuitCommand, PrintCommand, DeleteCommand

class SedliteParser:

    def __init__(self, script: str):
        self.script = script
        self.pos = 0
        self.length = len(script)

    def parse(self) -> List[Command]:
        commands = []
        while self.pos < self.length:
            self._skip_whitespace()
            if self.pos >= self.length:
                break

            char = self.script[self.pos]

            if char in (';', ',', '\n'):
                self.pos += 1
                continue

            if char == '#':
                self._skip_to_next_command()
                continue
                
            commands.append(self._parse_single_command())
        return commands

    def _skip_to_next_command(self):
        while self.pos < self.length and self.script[self.pos] not in ('\n', ',', ';'):
            self.pos += 1
    
    def _skip_whitespace(self):
        while self.pos < self.length and self.script[self.pos] in (' ', '\t'):
            self.pos += 1

    def _parse_address(self) -> Optional[str]:
        self._skip_whitespace()
        char = self.script[self.pos]

        if char.isdigit() or char == '$':
            start = self.pos
            if char == '$':
                self.pos += 1
            else:
                while self.pos < self.length and self.script[self.pos].isdigit():
                    self.pos += 1
            return self.script[start:self.pos]

        if char == '/':
            self.pos += 1
            pattern = self._read_until_unescaped('/')
            self.pos += 1
            return f"/{pattern}/"

        return None

    def _read_until_unescaped(self, delimiter: str) -> str:
        start = self.pos
        escaped = False

        while self.pos < self.length:
            
            char = self.script[self.pos]
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == delimiter:
                break
            self.pos += 1
        if self.pos >= self.length and self.script[self.pos-1] != delimiter:
            print("invalid command")
            sys.exit(1)

        return self.script[start:self.pos].replace(f'\\{delimiter}', delimiter)

    def _parse_single_command(self) -> Command:

        addr1 = self._parse_address()
        addr2 = None

        self._skip_whitespace()

        if self.pos < self.length and self.script[self.pos] == ',':
            self.pos += 1
            addr2 = self._parse_address()

        self._skip_whitespace()

        command = self.script[self.pos]
        self.pos += 1

        args = {}
        if command == 's':
            args = self._parse_substitute_args()
            return SubstituteCommand(
                addr1=addr1,
                addr2=addr2,
                pattern=args["pattern"],
                replacement=args["replacement"],
                flags=args["flags"]
            )
        elif command == 'q':
            if not addr2 == None:
                print(f"sedlite: command line: invalid command")
                sys.exit(1)
            return QuitCommand(addr1)
        elif command == 'p':
            return PrintCommand(addr1, addr2)
        elif command == 'd':
            return DeleteCommand(addr1, addr2)
        elif command == 's':
            return SubstituteCommand(addr1, addr2)
                
    def _parse_substitute_args(self) -> Dict[str, str]:

        delimiter = self.script[self.pos]
        
        self.pos += 1
        pattern = self._read_until_unescaped(delimiter)
        self.pos += 1
        replacement = self._read_until_unescaped(delimiter)
        self.pos += 1

        start_flags = self.pos
        while self.pos < self.length and self.script[self.pos].isalnum():
            self.pos += 1
        flags = self.script[start_flags:self.pos]

        return {
            "pattern" : pattern,
            "replacement" : replacement,
            "flags" : flags
        }