package main

import (
	"fmt"
	"os"

	"github.com/fatih/color"
	"github.com/rodaine/table"
)

var Version string = "0.0.0"
var Platform string = "macOS"
var AppName string = "merged-branches"

func main() {
	HandleKeyboardInterrupt(func() {
		SpinnerStop()
		Log("Cancelled.")
		os.Exit(1)
	})

	args := os.Args[1:]

	if Contains(args, "--help") || Contains(args, "-h") || Contains(args, "help") {
		PrintHelp(AppName, Version, Platform)

		os.Exit(0)
	}

	if Contains(args, "--version") || Contains(args, "-v") || Contains(args, "version") {
		Log(AppName, Version+"-"+Platform)

		os.Exit(0)
	}

	CheckGitFolder(func() {
		Log(color.RedString("!"), "Git folder not exists")
		os.Exit(1)
	})

	SpinnerStart()

	branchToCheck := "master"
	if len(args) > 0 {
		branchToCheck = args[0]
	}

	user := ""
	if len(args) > 1 {
		user = args[1]
	}

	SpinnerUpdate("Running git fetch...")
	_, _ = RunCMD("git", []string{"fetch", "-qp"})

	var branches = GetMergedBranches(user, branchToCheck)

	SpinnerStop()

	if len(branches) > 0 {
		tbl := table.New("User", "Branch", "Last Update")
		for _, branch := range branches {
			tbl.AddRow(branch.author, branch.branch, branch.date)
		}

		PrintTable(tbl)

		Log("\nTo delete branch use: git push origin --delete [branchName]")

		os.Exit(0)
	}

	var resultText string = "Not found any branch that merged into " + branchToCheck
	if user != "" {
		resultText = resultText + " by " + user
	}

	Log(resultText + " and not deleted.")
}

func PrintHelp(appName string, version string, platform string) {
	var helpString = `%s %s-%s

Options:
	-h, --help       Print help
	-v, --version    Print version
	[branch]         Branch to lookup (Default: master)
	[user]           Name of user to filter

Usage:
	%s [branch] [user]
	%s (-h | --help)
	%s (-v | --version)
`

	fmt.Printf(helpString, appName, version, platform, appName, appName, appName)
}
