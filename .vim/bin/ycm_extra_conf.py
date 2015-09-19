#!/usr/bin/env python
#
# Behave similar to clang_complete by default.

import os

DEFAULT_FLAGS = [ '-Wall', '-Wextra', '-Werror' ]

CLANG_COMPLETE = '.clang_complete'

def FileDependentFlags(filename):
    ext = filename.split('.')[-1]
    if ext in ['cpp', 'cc', 'hpp', 'hh']:
        return ['-std=c++11', '-x', 'c++']
    elif ext in ['c']:
        return ['-std=c99', '-x', 'c']
    return []

def AppendFromClangComplete(filename, flags):
    curpath = os.path.abspath(filename)
    for depth in range(10):
        nextpath = os.path.normpath(os.path.join(curpath, os.path.pardir))
        if curpath == nextpath: break
        curpath = nextpath

        cc = os.path.join(curpath, CLANG_COMPLETE)

        if os.path.exists(cc):
            with open(cc, 'r') as f:
                for line in f:
                    line = line.strip()

                    # Expand relative paths
                    if line.startswith('-I'):
                        include_path = line[2:]
                        if not include_path.startswith('/'):
                            include_path = os.path.join(curpath, include_path)
                            line = '-I' + os.path.normpath(include_path)

                    flags.append(line)
                return True

    return False

def FlagsForFile(filename, **kwargs):
    flags = [ '-isystem',
              '/usr/include',
              '-isystem',
              '/usr/local/include' ]

    if not AppendFromClangComplete(filename, flags):
        flags += DEFAULT_FLAGS
        flags += FileDependentFlags(filename)

    return { 'flags'   : flags,
             'do_cache': True }

