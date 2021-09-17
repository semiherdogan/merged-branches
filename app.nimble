# Package

version         = "0.3.1"
author          = "Semih ERDOGAN"
description     = "Get merged branch list"
license         = "MIT"
srcDir          = "src"
bin             = @["app"]
namedBin        = {"app": "merged-branches"}.toTable()


# Dependencies

requires "nim >= 1.0.0"
requires "https://github.com/molnarmark/spinny#882fc39018ca0ddd42e76f091a0aae98d8e83582"
requires "https://github.com/xmonader/nim-terminaltables#37981f5d403fb55688e00d24ab9b1d56e252f52b"
