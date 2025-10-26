package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/fatih/color"
	"github.com/rodaine/table"
	"github.com/semiherdogan/merged-branches/internal/config"
	"github.com/semiherdogan/merged-branches/internal/git"
	"github.com/semiherdogan/merged-branches/internal/ui"
	"github.com/semiherdogan/merged-branches/internal/utils"
)

var (
	appInfo = config.GetAppInfo()
)

func main() {
	utils.HandleKeyboardInterrupt(func() {
		ui.SpinnerStop()
		ui.Log("Cancelled.")
		os.Exit(1)
	})

	args := os.Args[1:]

	// Handle version flag
	if utils.Contains(args, "--version") || utils.Contains(args, "-v") {
		ui.Logf("%s version %s (%s)\n", appInfo.Name, appInfo.Version, appInfo.Platform)
		os.Exit(0)
	}

	// Handle help flag
	if utils.Contains(args, "--help") || utils.Contains(args, "-h") {
		PrintHelp()
		os.Exit(0)
	}

	// Filter out any flags that might be mixed in with positional arguments
	filteredArgs := make([]string, 0, len(args))
	for _, arg := range args {
		if !strings.HasPrefix(arg, "-") {
			filteredArgs = append(filteredArgs, arg)
		}
	}
	args = filteredArgs

	if err := ensureGitRepo(); err != nil {
		exitWithError(err)
	}

	// Get branch to check (first argument or ask interactively)
	var branchToCheck string
	if len(args) > 0 {
		branchToCheck = args[0]
	} else {
		branchToCheck = GetUserInput("Merged to?: ")
		if branchToCheck == "" {
			ui.Log("No branch specified. Exiting.")
			os.Exit(1)
		}
	}

	ui.SpinnerStart()

	// Get user filter (second argument)
	user := ""
	if len(args) > 1 {
		user = args[1]
	}

	branches, err := git.GetMergedBranches(user, branchToCheck)
	if err != nil {
		exitWithError(fmt.Errorf("failed to get merged branches: %w", err))
	}

	ui.SpinnerStop()

	if len(branches) == 0 {
		ui.Log("No merged branches found.")
		return
	}

	headerFmt := color.New(color.FgGreen, color.Underline).SprintfFunc()
	columnFmt := color.New(color.FgYellow).SprintfFunc()

	tbl := table.New("Branch", "Author", "Last Commit Date")
	tbl.WithHeaderFormatter(headerFmt).WithFirstColumnFormatter(columnFmt)

	for _, branch := range branches {
		tbl.AddRow(branch.Branch, branch.Author, branch.Date)
	}

	tbl.Print()
}

// ensureGitRepo checks if the current directory is a git repository
func ensureGitRepo() error {
	if _, err := os.Stat(".git"); os.IsNotExist(err) {
		return fmt.Errorf("not a git repository (or any of the parent directories): .git")
	}
	return nil
}

// exitWithError prints an error message and exits with status code 1
func exitWithError(err error) {
	ui.SpinnerStop()
	ui.Log(color.RedString("Error:"), err)
	os.Exit(1)
}

func GetUserInput(prompt string) string {
	ui.SpinnerStop()
	fmt.Print(prompt)

	var input string
	_, err := fmt.Scanln(&input)
	if err != nil {
		return ""
	}

	return strings.TrimSpace(input)
}

// PrintHelp prints the help message to the standard output
func PrintHelp() {
	appInfo := config.GetAppInfo()
	helpText := fmt.Sprintf(`%s - A command-line utility to list merged Git branches

Version: %s
Platform: %s

Usage: %s [branch] [user]

Find merged branches in a Git repository.

Arguments:
  branch    The target branch to check for merged branches (default: asks for input)
  user      Filter branches by author (optional)

Options:
  -h, --help     Show this help message
  -v, --version  Show version information

Examples:
  %s                    # Interactive mode
  %s main              # Show branches merged into main
  %s main "John Doe"   # Show branches merged into main by John Doe`,
		appInfo.Name,
		appInfo.Version,
		appInfo.Platform,
		appInfo.Name,
		appInfo.Name,
		appInfo.Name,
		appInfo.Name,
	)

	ui.Log(helpText)
}
