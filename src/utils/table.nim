from terminaltables import newTerminalTable, printTable, addRow, setHeaders, suggestWidths
from algorithm import sortedByIt
from strutils import toLowerAscii

type
  Branch* = object
    author*: string
    name*: string

let outputTable = newTerminalTable()
outputTable.separateRows = false
outputTable.setHeaders(@["User", "Branch"])

proc printBranchesTable*(rows: seq[Branch]): void =
  # Sort by author name
  for row in rows.sortedByIt(it.author.toLowerAscii):
    outputTable.addRow(@[
      row.author,
      row.name
    ])

  printTable(outputTable)
