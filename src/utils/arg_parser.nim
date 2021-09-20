from ../../constants import TAG, PLATFORM

proc printHelp(): void =
  echo """Usage: merged-branches [branch] [user]
  [branch] Branch to check merge. (Default: master)
  [user]   Branch last committer.

Example: merged-branches main myuser
"""

proc printVersion(): void =
  echo "Version: ", TAG, "-", PLATFORM
  echo "Release link: https://github.com/semiherdogan/merged-branches/releases/tag/", TAG

proc parseArgs*(argv: string): void =
  if argv == "--help" or argv == "-h":
    printHelp()
    quit(QuitSuccess)

  if argv == "--version" or argv == "-v":
    printVersion()
    quit(QuitSuccess)
