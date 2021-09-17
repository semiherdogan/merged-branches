from ../../constants import VERSION

proc printHelp(): void =
  echo """Usage: merged-branches [branch] [user]
  [branch] Branch to check merge. (Default: master)
  [user]   Branch last committer.

Example: merged-branches main myuser
"""

proc printVersion(): void =
  echo "Version: ", VERSION
  echo "Release link: https://github.com/semiherdogan/merged-branches/releases/tag/", VERSION

proc parseArgs*(argv: string): void =
  if argv == "--help":
    printHelp()
    quit(QuitSuccess)

  if argv == "--version":
    printVersion()
    quit(QuitSuccess)
