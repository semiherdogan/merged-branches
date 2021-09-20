from unicode import runeLen, runeAtPos, toUTF8
from strutils import replace

proc replaceUnicodeChars*(str: string): string =
  const find: string = "üğışçöÜĞİŞÇÖ"
  const replace: string = "ugiscoUGISCO"

  result = str
  for k in 0..<find.runeLen:
    result = result.replace(
      find.runeAtPos(k).toUTF8(),
      replace.runeAtPos(k).toUTF8()
    )
