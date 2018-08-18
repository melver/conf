#!/usr/bin/env python
#
# Behave similar to clang_complete by default.

import os
import string

DEFAULT_FLAGS = [ '-Wall', '-Wextra', '-Werror' ]

CLANG_COMPLETE = '.clang_complete'

def FileDependentFlags(filename):
    ext = filename.split('.')[-1]
    if ext in ['cpp', 'cc', 'hpp', 'hh', 'cxx']:
        return ['-std=c++17']
    elif ext in ['c']:
        return ['-std=c99']
    return []

def FixFileType(filename):
    ext = filename.split('.')[-1]
    if ext in ['cppm', 'ixx']:
        return ['-x', 'c++-module']
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
                for arg in f:
                    arg = arg.strip()
                    if not arg: continue

                    # Expand relative paths
                    if arg.startswith('-I'):
                        include_path = arg[2:]
                        if not include_path.startswith('/'):
                            include_path = os.path.join(curpath, include_path)
                            arg = '-I' + os.path.normpath(include_path)
                    elif arg.startswith('-fmodule-file='):
                        module = None
                        # Find module name from source file
                        with open(filename, 'r') as f:
                            line_num = 0
                            for line in f:
                                # only check first 100 lines
                                line_num += 1
                                if line_num > 100: break
                                if line.startswith('module'):
                                    module = line.split()[-1].strip(";")
                                    break

                        # If not found, skip this arg.
                        if module is None: continue
                        arg = string.Template(arg).substitute(module=module)

                    flags.append(arg)
                return True

    return False

def FlagsForFile(filename, **kwargs):
    flags = FixFileType(filename)

    if not AppendFromClangComplete(filename, flags):
        flags += DEFAULT_FLAGS
        flags += FileDependentFlags(filename)

    return { 'flags'   : flags,
             'do_cache': True }

