"""Tiny shell helpers — the bits we actually used from `ok`."""
import json
import os
import subprocess

HOME = os.path.expanduser("~")
BASH = "/bin/bash"  # so brace expansion `{a,b}` and `[...]` work


def sh(cmd, check=True):
    """Run CMD in bash, inheriting stdio. Raises on failure unless check=False."""
    return subprocess.run(cmd, shell=True, executable=BASH, check=check)


def cap(cmd):
    """Run CMD in bash, return stripped stdout."""
    return subprocess.run(
        cmd, shell=True, executable=BASH, text=True, capture_output=True
    ).stdout.strip()


def ok(cmd):
    """True if CMD exits 0 (output discarded)."""
    return subprocess.run(
        cmd, shell=True, executable=BASH,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    ).returncode == 0


def cfg(path):
    """Load JSON from PATH."""
    with open(path) as f:
        return json.load(f)
