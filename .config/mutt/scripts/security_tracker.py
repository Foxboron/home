#!/usr/bin/python

import sys
import subprocess
import re
import requests


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

    def __init__(self):
        self.colors = {
                'black': '\033[90m',
                'red': '\033[91m',
                'green': '\033[92m',
                'yellow': '\033[93m',
                'blue': '\033[94m',
                'magenta': '\033[95m',
                'cyan': '\033[96m',
                'white': '\033[97m',
                'reset': '\033[0m',
                'bold': '\033[1m',
                'underline': '\033[4m',
                }

    def _print(self, symbol, text, c=""):
        print("{c}{symbol}{end} {text}".format(c=c, end=self.ENDC,
                                            text=text, symbol=symbol))

    def title(self, text):
        self._print("::", text, c=self.OKBLUE)

    def info(self, text):
        self._print(" ->", text, c=self.OKGREEN)

    def infow(self, text):
        self._print(" ->", text, c=self.WARNING)

    def infob(self, text):
        self._print(" ->", text, c=self.OKGREEN)

    def msg(self, text):
        self._print("==>",text, c=self.WARNING)
p = bcolors()


url_json = 'https://security.archlinux.org/{}/json'
url= 'https://security.archlinux.org/{}'


if __name__ == "__main__":
    matches = set(re.findall("CVE-\d{4}-\d*", sys.stdin.read()))
    for match in matches:
        r = requests.get(url_json.format(match))
        if r.status_code == 200:
            cve = r.json()
            groups = cve["groups"]
            p.title(match)
            p.info("Package: {}".format(" ".join(cve["packages"])))
            p.info("URL: {}".format(url.format(match)))
            for group in groups:
                r = requests.get(url_json.format(group))
                if r.status_code == 200:
                    group = r.json()
                    p.msg("Part of {}".format(group["name"]))
                    p.info("URL: {}".format(url.format(group["name"])))
                    p.infow("Status: {}".format(group["status"]))
                    if group["advisories"]:
                        for asa in group['advisories']:
                            p.info("Published as part of {}".format(asa))
                    else:
                        p.msg("No published ASA for this CVE")
            print("")
        else:
            p.msg("No CVE for: {}".format(match))
