from parsecfg import loadConfig, Config, getSectionValue

proc printHelp(): void =
  echo """Usage: merged-branches [branch] [user]
  [branch] Branch to check merge. (Default: master)
  [user]   Branch last committer.

Example: merged-branches main myuser
"""

proc printVersion(): void =
  let packageConfig: Config = loadConfig("version.cfg")
  let tag = packageConfig.getSectionValue("", "tag")
  let platform = packageConfig.getSectionValue("", "platform")

  echo "Version: ", tag, "-", platform
  echo "Release link: https://github.com/semiherdogan/merged-branches/releases/tag/", tag

proc parseArgs*(argv: string): void =
  if argv == "--help" or argv == "-h":
    printHelp()
    quit(QuitSuccess)

  if argv == "--version" or argv == "-v":
    printVersion()
    quit(QuitSuccess)
