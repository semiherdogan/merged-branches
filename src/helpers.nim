from unicode import runeLen, runeAtPos, toUTF8
from strutils import replace

proc replaceUnicodeCharacters*(str: string): string =
  const find: string = "üğışçöÜĞİŞÇÖ"
  const replace: string = "ugiscoUGISCO"

  var strResult: string = str
  for k in 0..(find.runeLen-1):
    strResult = strResult.replace(
      find.runeAtPos(k).toUTF8(),
      replace.runeAtPos(k).toUTF8()
    )

  return strResult
