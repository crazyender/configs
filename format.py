#!/usr/bin/python
from commands import getstatusoutput
import sys

W  = '\033[0m'  # white (normal)
R  = '\033[31m' # red
G  = '\033[32m' # green
O  = '\033[33m' # orange
B  = '\033[34m' # blue
P  = '\033[35m' # purple

format_file_type = [
        ".c",
        ".h",
        ".cpp"
]

status, output = getstatusoutput("git show --pretty=\"\" --name-only")
lines = output.split("\n")
files = [line for line in lines if len(line) != 0]
for file_name in files:
        needs = False
        for ext in format_file_type:
                if file_name.endswith(ext):
                        needs = True;
        if not needs:
                continue
        cmd = "git-clang-format --commit HEAD~1 --style=file " + file_name
        sys.stdout.write(cmd)
        status, output = getstatusoutput(cmd)
        sys.stdout.write(" -- ");
        statustxt = "";
        if status != 0:
            print(R + "FAIL" + W)
        else:
            print(G + "DONE" + W)
