# Merged-Branches (List merged branches from git)

## Installation
__NOTE__: Before install this package, you should have `git` and `grep` installed on your machine.


* Download standalone binary for apple from [releases](https://github.com/semiherdogan/merged-branches/releases).
* Move downloaded file to path like `mv merged-branches-apple-intel /usr/local/bin/merged-branches`.

* Or you can download source code and compile on your own. (You may check [build.sh](build.sh) file)

## Usage
`merged-branches [branchName] [user]`

* To see list of branches that merged into main branch and not deleted use example below:
```
$ merged-branches main
```

* Give `--help` to get help string.
```
$ merged-branches --help

Usage: merged-branches [branch] [user]
  [branch] Branch to check merge. (Default: master)
  [user]   Branch last committer.

Example: merged-branches main myuser
```

* Give `--version` to get app version.
```
$ merged-branches --version
```

## Todo
* [ ] Add platform info into version example: "Version: 0.3.0-macos-arm64"

## License

The MIT License (MIT). Please see [License File](LICENSE) for more information.
