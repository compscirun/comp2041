from abc import ABC, abstractmethod
from typing import Optional, Dict, List, Any

import re

class Command(ABC):

    def __init__(self, addr1: Optional[str], addr2 : Optional[str]):
        self.addr1 = addr1
        self.addr2 = addr2
        self.is_in_range = False

    def matches_address(self, context, address) -> bool:
        if address is None:
            return True

        if address == '$':
            return context.is_last_line
        if address.isdigit():
            return context.curr_index == int(address)

        if address.startswith('/') and address.endswith('/'):
            pattern = address[1:-1]
            return bool(re.search(pattern, context.curr_line))

        return False

    def in_range(self, context) -> bool:
        if self.addr1 is None and self.addr2 is None:
            return True
        if self.addr2 is None:
            return self.matches_address(context, self.addr1)

        if not self.is_in_range:
            if self.matches_address(context, self.addr1):
                self.is_in_range = True

                if self.addr2.isdigit() and context.curr_index >= int(self.addr2):
                    self.is_in_range = False
                return True
            
            return False
        else:
            if self.matches_address(context, self.addr2):
                self.is_in_range = False
            return True
    
    @abstractmethod
    def execute(self, context, input):
        pass

class QuitCommand(Command):
    def __init__(self, addr1: Optional[str]):
        super().__init__(addr1, None)

    def __repr__(self) -> str:
        return f"QuitCommand(address='{self.addr1}')"
    
    def execute(self, context):
        if self.matches_address(context, self.addr1):
            context.has_quit = True

class PrintCommand(Command):
    def __init__(self, addr1: Optional[str], addr2 : Optional[str]):
        super().__init__(addr1, addr2)

    def __repr__(self) -> str:
        return f"PrintCommand(address='{self.addr1s}')"

    def execute(self, context):
        if self.in_range(context):
            print(context.curr_line, end="")

class DeleteCommand(Command):
    def __init__(self, addr1: Optional[str], addr2: Optional[str]):
        super().__init__(addr1, addr2)

    def __repr__(self) -> str:
        return f"DeleteCommand(address='{self.address}')"

    def execute(self, context):
        if self.in_range(context):
            context.is_deleted = True

class SubstituteCommand(Command):
    def __init__(self, addr1: Optional[str], addr2: Optional[str], pattern: str, replacement: str, flags : Optional[str]):
        super().__init__(addr1, addr2)
        self.pattern = pattern
        self.replacement = replacement
        self.flags = flags

    def __repr__(self) -> str:
        addr_str = f"address='{self.address}', " if self.address else ""
        return (f"SubstituteCommand({addr_str}pattern='{self.pattern}', "
                f"replacement='{self.replacement}', is_global={self.is_global})")
    
    def execute(self, context):
        if self.in_range(context):
            if 'g' in self.flags:
                context.curr_line = re.sub(self.pattern, self.replacement, context.curr_line)
            else:
                context.curr_line = re.sub(self.pattern, self.replacement, context.curr_line, count=1)