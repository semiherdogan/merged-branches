from strutils import strip

from spinner import spinnerStop

proc printHelp(): void =
  echo """Usage: merged-branches [branch] [user]
  [branch] Branch to check merge. (Default: master)
  [user]   Branch last committer.

Example: merged-branches main myuser
"""

proc parseArgv*(argv: string): string =
  const helpCommands: array[6, string] = ["--help", "-help", "-h", "--h", "/?", "?"]
  if argv in helpCommands:
    spinnerStop()
    printHelp()
    quit(QuitSuccess)

  return argv.strip()
