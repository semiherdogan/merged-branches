from terminaltables import newTerminalTable, printTable, addRow, setHeaders, suggestWidths
from spinny import newSpinny, setSymbolColor, start, error, success, Dots,
    fgLightGreen, fgGreen
from algorithm import sortedByIt
from strutils import split, strip, replace, toLowerAscii, toLower, contains
from sequtils import mapIt, filterIt
from osproc import execProcess
from os import getCurrentDir, dirExists, paramCount, paramStr
from helpers import replaceUnicodeCharacters
from unicode import runeLen

# Initialize the spinny
let spinner = newSpinny("Loading..".fgLightGreen, Dots)
spinner.setSymbolColor(fgGreen)
spinner.start()

if dirExists(".git/") == false:
  spinner.error("Git repo NOT found")
  quit(QuitFailure)

# get latest changes from git before starting
discard execProcess("git fetch -qp")

# get branch name as first argument
var remoteBranchToCheck: string = "origin/master"
if paramCount() > 0:
  remoteBranchToCheck = "origin/" & paramStr(1)

# get username as second argument
var userTocheck = ""
if paramCount() > 1:
  userTocheck = paramStr(2).replaceUnicodeCharacters().toLower()

# gets branchname and branch author separated by "---"
# Example: [myBranch---Semih ERDOGAN]
let branchAuthors = execProcess(
  "git for-each-ref --format=\"%(refname:strip=3)---%(authorname)\" --sort=authordate refs/remotes"
)
.split("\n")
.filterIt(it.len > 1)
.mapIt(it.split("---"))

# get branch name and latest commit hash
# Example: [5ce2envhd00cce33effa587ay2d, myBranch]
let branches = execProcess(
  r"git ls-remote | grep -v 'tags\|HEAD\|From\|/master\|/test\|dev\|release'"
)
.split("\n")
.filterIt(it.len > 1)
.mapIt(it.split("\trefs/heads/"))
.filterIt(it.len > 1)

type
  Branch = object
    name: string
    author: string

var result: seq[Branch] = @[]

# Check if given remove branch contains this branch's latest commit hash
for branch in branches:
  let branchExistsInMergedList: string = execProcess(
    "git branch -r --contains " & branch[0] & " | grep '" &
        remoteBranchToCheck & "$' | grep -vi 'head'"
  ).strip()

  if branchExistsInMergedList.len > 0 and branchExistsInMergedList == remoteBranchToCheck:
    let currentBranchInfo = branchAuthors.filterIt(it[0] == branch[1])[0]

    result.add(
      Branch(
        name: currentBranchInfo[0],
        author: currentBranchInfo[1]
      )
    )

# Initiate output table
let outputTable = newTerminalTable()
outputTable.separateRows = false
outputTable.setHeaders(@["User", "Branch"])

# Iterate over all branches sort by user and filter by user
var exists: bool = false
for r in result.sortedByIt(it.author.toLowerAscii):
  if userTocheck != "" and not r.author.replaceUnicodeCharacters().toLower().contains(userTocheck):
    continue

  exists = true
  outputTable.addRow(@[
    r.author,
    r.name
  ])

# No branch found
if not exists:
  spinner.success("Not found any branch that merged into " & remoteBranchToCheck)
  quit(QuitSuccess)

# echo table
spinner.success("Branches that merged into " & remoteBranchToCheck & ":")
printTable(outputTable)
echo "To delete branch use: git push origin --delete [branchName]"
