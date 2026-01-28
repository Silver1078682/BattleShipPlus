"""
Custom gdscript linter
"""

from abc import abstractmethod
from functools import lru_cache
import re
import os


RESET = "\033[0m"
CYAN = 36


def print_colored_text(text, color_code):
    print(f"\033[{color_code}m{text}{RESET}")


def remove_comment(line: str) -> str:
    double = len(line) if (at := line.find('"')) == -1 else at
    single = len(line) if (at := line.find("'")) == -1 else at
    comment = len(line) if (at := line.find("#")) == -1 else at
    if comment < double and comment < single:
        line = line[:comment]
        return line

    def skip_string(char: str, opening_pair_at: int):
        while (closing_pair_at := line.find(char, opening_pair_at + 1)) != -1:
            if line[closing_pair_at - 1] == "\\":
                opening_pair_at = closing_pair_at
                continue
            break
        if closing_pair_at < opening_pair_at:
            return line
        return line[: closing_pair_at + 1] + remove_comment(line[closing_pair_at + 1 :])

    if double < single and double < comment:
        return skip_string('"', double)
    if single < double and single < comment:
        return skip_string("'", single)
    return line


class LintRule:
    """
    linting rules
    """

    def __init__(self) -> None:
        pass

    @abstractmethod
    def lint(self, linter) -> bool | str:
        pass


class MethodWithoutReturnType(LintRule):
    """
    Method without return type
    """

    def lint(self, linter) -> bool | str:
        if not "->" in linter.line and not linter.line.endswith("("):
            return " Method without return type"
        return False


class ClassNameMatchFile(LintRule):
    """
    Class name does not match file name"
    """

    def lint(self, linter) -> bool | str:
        class_name = linter.line.split()[1]
        pascal_case = "".join(word.capitalize() for word in linter.file_name.split("_"))
        if class_name != pascal_case:
            return "Class name does not match file name"
        return False


class Linter:
    """
    Lint a directory
    """

    def __init__(self, include_private=False) -> None:
        self.include_private = include_private
        self.file_path: str
        self.file_name: str
        self.line_idx: int
        self.line: str

    def get_files_in_directory(
        self, directory: str, file_name_regex: str
    ) -> list[tuple[str, str]]:
        """
        Find all files in a given directory recursively.
        """
        files: list[tuple[str, str]] = []
        try:
            with os.scandir(directory) as entries:
                for entry in entries:
                    if entry.is_file() and re.match(file_name_regex, entry.name):
                        files.append((entry.path, entry.name.removesuffix(".gd")))
                    elif entry.is_dir():
                        files.extend(
                            self.get_files_in_directory(entry.path, file_name_regex)
                        )
        except PermissionError:
            print(f"Permission denied for directory: {directory}")
        return files

    def get_lines_in_file(self, file_path: str) -> list[tuple[int, str]]:
        lines: list[tuple[int, str]] = []
        try:
            with open(file_path, "r", encoding="utf-8") as file:
                for line_number, line in enumerate(file, start=1):
                    lines.append((line_number, line.strip()))
        except FileNotFoundError:
            print(f"The file at {file_path} was not found.")
        return lines

    def _match_rule(
        self,
        lint_rule: LintRule,
    ) -> None:
        if not (lint_result := lint_rule.lint(self)):
            return
        print_colored_text(f">>>{self.file_path} line {self.line_idx}", CYAN)
        print(f"{lint_result} {self.line}")

    def lint_directory(self, directory: str):
        """
        Lint a directory
        """
        files = self.get_files_in_directory(directory, r"^.*\.gd$")
        for file_path, file_name in files:
            self.file_path = file_path
            self.file_name = file_name
            self.line = ""
            multiline: bool = False
            expected_closing_pair: str = ""

            for line_idx, single_line in self.get_lines_in_file(file_path):
                if not (current_line := single_line.strip()):
                    continue

                current_line = remove_comment(current_line)
                if not current_line:
                    continue

                if multiline:
                    self.line += current_line
                    multiline = False
                elif expected_closing_pair:
                    self.line += current_line
                    if self.line.find(expected_closing_pair) != -1:
                        expected_closing_pair = ""
                    else:
                        continue
                else:
                    self.line = current_line

                if current_line.endswith("/"):
                    multiline = True
                    continue
                if (last_char := current_line[-1]) in "([{":
                    expected_closing_pair = COUNTER_PAIR[last_char]
                    continue

                self.line_idx = line_idx
                if self.line.startswith("class_name"):
                    self._match_rule(ClassNameMatchFile())

                if re.match(r"^(static\s+)?func\s+", self.line):
                    self._match_rule(MethodWithoutReturnType())


COUNTER_PAIR = {
    "(": ")",
    "[": "]",
    "{": "}",
}

a_linter = Linter()
a_linter.lint_directory("/home/silver/Desktop/battleship/src")
