from parsecfg import loadConfig, Config, getSectionValue

proc printHelp(): void =
  echo """Usage: merged-branches [branch] [user]
  [branch] Branch to check merge. (Default: master)
  [user]   Branch last committer.

Example: merged-branches main myuser
"""

proc printVersion(): void =
  let packageConfig: Config = loadConfig("app.nimble")
  let appVersion = packageConfig.getSectionValue("", "version")

  echo "Version: ", appVersion
  echo "Release link: https://github.com/semiherdogan/merged-branches/releases/tag/", appVersion

proc parseArgs*(argv: string): void =
  if argv == "--help":
    printHelp()
    quit(QuitSuccess)

  if argv == "--version":
    printVersion()
    quit(QuitSuccess)
