#!/usr/bin/env python

##
# @file gpg_mutt_secrets.py
# Can be used as a 'pythonfile' for offlineimap.
#
# @author Marco Elver <me AT marcoelver.com>
# @date Sun  9 Dec 23:01:30 GMT 2012

import os
import subprocess

SECRETS_FILE = os.path.join(os.environ["HOME"], ".mutt", "local", "secrets.gpg")

def get_mutt_secrets_var(var_name):
    var_name = var_name.encode()
    gpg = subprocess.Popen(["gpg", "-dq", SECRETS_FILE], stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
    secrets = gpg.communicate()[0]

    secrets = secrets.split()
    for i,token in enumerate(secrets):
        if token == var_name:
            return secrets[i+2]

    return ""

if __name__ == "__main__":
    import sys
    print(get_mutt_secrets_var(sys.argv[1]).decode())
    sys.exit(0)

