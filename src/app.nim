from strutils import split, strip, toLower, contains
from sequtils import mapIt, filterIt
from osproc import execProcess
from os import dirExists, paramCount, paramStr
from utils/replace_unicode_characters import replaceUnicodeCharacters
from utils/spinner import spinnerStart, spinnerSuccess, spinnerError, spinnerText
from utils/table import printBranchesTable, Branch
from utils/arg_parser import parseArgs

if paramCount() > 0:
  parseArgs(paramStr(1))

spinnerStart()

if dirExists(".git/") == false:
  spinnerError("Git repo NOT found")
  quit(QuitFailure)

# get branch name as first argument
var remoteBranchToCheck: string = "origin/master"
if paramCount() > 0:
  remoteBranchToCheck = "origin/" & paramStr(1)

# get username as second argument
var userTocheck = ""
if paramCount() > 1:
  userTocheck = paramStr(2).replaceUnicodeCharacters().toLower()

spinnerText("Running 'git fetch'")
discard execProcess("git fetch -qp")

# gets branchname and branch author separated by "---"
# Example: [myBranch---Semih ERDOGAN]
spinnerText("Getting branch and author info")
let branchAuthors = execProcess(
  "git for-each-ref --format=\"%(refname:strip=3)---%(authorname)\" --sort=authordate refs/remotes"
)
.split("\n")
.filterIt(it.len > 1)
.mapIt(it.split("---"))

# get branch name and latest commit hash
# Example: [5ce2envhd00cce33effa587ay2d, myBranch]
spinnerText("Getting remote branch list")
let branches = execProcess(
  r"git ls-remote | grep -v 'tags\|HEAD\|From\|/master\|/test\|dev\|release'"
)
.split("\n")
.filterIt(it.len > 1)
.mapIt(it.split("\trefs/heads/"))
.filterIt(it.len > 1)

var branchAuthorResult: seq[Branch] = @[]

spinnerText("Checking branches and commits")
for branch in branches:
  # get branches that has a commit with the same hash as the latest commit
  let branchExistsInMergedList: string = execProcess(
    "git branch -r --contains " & branch[0] & " | grep '" &
        remoteBranchToCheck & "$' | grep -vi 'head'"
  ).strip()

  # Check if given remove branch contains this branch's latest commit hash
  if branchExistsInMergedList.len > 0 and branchExistsInMergedList == remoteBranchToCheck:
    var currentBranchInfo = branchAuthors.filterIt(it[0] == branch[1])[0]

    # Check if the author is the given user
    if userTocheck != "" and not currentBranchInfo[1].replaceUnicodeCharacters().toLower().contains(userTocheck):
      continue

    branchAuthorResult.add(
      Branch(
        author: currentBranchInfo[1],
        name: currentBranchInfo[0]
      )
    )

# No result
if branchAuthorResult.len == 0:
  spinnerSuccess("Not found any branch that merged into " & remoteBranchToCheck)
  quit(QuitSuccess)

# Echo result
spinnerSuccess("Branches that merged into " & remoteBranchToCheck & ":")
printBranchesTable(branchAuthorResult)
echo "To delete branch use: git push origin --delete [branchName]"
