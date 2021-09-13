import terminaltables
import spinny
from algorithm import sortedByIt
from strutils import split, strip, replace, toLowerAscii, toLower, contains
from sequtils import mapIt, filterIt
from osproc import execProcess
from os import getCurrentDir, dirExists, paramCount, paramStr

let spinner = newSpinny("Loading..".fgWhite, Dots)
spinner.setSymbolColor(fgBlue)
spinner.start()

type
  Branch = object
    name: string
    author: string

if dirExists(".git/") == false:
  spinner.error("Git repo NOT found")
  quit(QuitFailure)

discard execProcess("git fetch -qp")

var remoteBranchToCheck: string = "origin/master"
if paramCount() > 0:
  remoteBranchToCheck = "origin/" & paramStr(1)

var userTocheck = ""
if paramCount() > 1:
  userTocheck = paramStr(2).toLower()

let branchAuthors = execProcess(
  "git for-each-ref --format=\"%(refname:strip=3)---%(authorname)\" --sort=authordate refs/remotes"
)
.split("\n")
.filterIt(it.len > 1)
.mapIt(it.split("---"))

let branches = execProcess(
  r"git ls-remote | grep -v 'tags\|HEAD\|From\|/master\|/test\|dev\|release'"
)
.split("\n")
.filterIt(it.len > 1)
.mapIt(it.split("\trefs/heads/"))
.filterIt(it.len > 1) # remove from repository line !

var result: seq[Branch] = @[]

for branch in branches:
  let branchExistsInMergedList: string = execProcess(
    "git branch -r --contains " & branch[0] & " | grep '" & remoteBranchToCheck & "$' | grep -vi 'head'"
  ).strip()

  if branchExistsInMergedList.len > 0 and branchExistsInMergedList == remoteBranchToCheck:
    let currentBranchInfo = branchAuthors.filterIt(it[0] == branch[1])[0]

    result.add(
      Branch(
        name: currentBranchInfo[0],
        author: currentBranchInfo[1]
      )
    )

let outputTable = newTerminalTable()
outputTable.separateRows = false
outputTable.setHeaders(@["User", "Branch"])

var exists: bool = false
for r in result.sortedByIt(it.author.toLowerAscii):
  if userTocheck != "" and not r.author.toLower().contains(userTocheck):
    continue

  exists = true
  outputTable.addRow(@[
    r.author
      .replace("ç", "c")
      .replace("ş", "s")
      .replace("ğ", "g"),
    r.name
  ])

if not exists:
  spinner.success("Not found any branch that merged into " & remoteBranchToCheck)
  quit(QuitSuccess)

spinner.success("Branches that merged into " & remoteBranchToCheck & ":")
printTable(outputTable)
echo "To delete branch use: git push origin --delete [branchName]"
