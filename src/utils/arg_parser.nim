from ../../constants import TAG, PLATFORM
from os import commandLineParams
from parseopt import initOptParser, getopt, cmdLongOption, cmdShortOption

proc printHelp(): void =
  echo """
"merged-branches" shows merged branches for given branch.

Usage:
    merged-branches [branch] [user]
    merged-branches (-h | --help)
    merged-branches (-v | --version)

Options:
    -h, --help           Print this help
    -v, --version        Print this version
    [branch]             Branch to check merge (Default: master)
    [user]               Branch last committer (Default: "")

Example:
    merged-branches main myuser
  """


proc printVersion(): void =
  echo "Version: ", TAG, "-", PLATFORM
  echo "Release link: https://github.com/semiherdogan/merged-branches/releases/tag/", TAG

proc parseArgs*(argv: string): void =
  var optParser = initOptParser(commandLineParams())

  for kind, key, val in optParser.getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        printHelp()
        quit(QuitSuccess)
      of "version", "v":
        printVersion()
        quit(QuitSuccess)
    else: discard
