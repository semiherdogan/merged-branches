// Package git provides functionality to interact with Git repositories
package git

import (
	"fmt"
	"sort"
	"strings"

	"github.com/semiherdogan/merged-branches/internal/utils"
)

// Common errors
var (
	ErrNoBranchesFound = fmt.Errorf("no branches found")
)

// Branch represents a git branch with its name and commit hash
type Branch struct {
	Name string `json:"name"` // Branch name
	Hash string `json:"hash"` // Commit hash the branch points to
}

// BranchAuthor represents a git branch along with its author and last commit date
type BranchAuthor struct {
	Author string `json:"author"` // Author of the last commit
	Branch string `json:"branch"` // Branch name
	Date   string `json:"date"`   // Last commit date in YYYY-MM-DD format
}

// GetBranches retrieves a list of all branches from the git repository
// branchToCheck is an optional parameter to filter branches
func GetBranches(branchToCheck string) ([]Branch, error) {
	output, err := utils.RunShellCommand("git", []string{
		"ls-remote",
		"--heads",
		"origin",
	})

	if err != nil {
		return nil, fmt.Errorf("failed to list remote branches: %w", err)
	}

	var branches []string = utils.Filter(strings.Split(output, "\n"), func(s string) bool {
		return len(s) > 0 &&
			!strings.Contains(s, "HEAD") &&
			!strings.Contains(s, "refs/tags/") &&
			!strings.Contains(s, "refs/heads/"+branchToCheck) &&
			!strings.Contains(s, "From ")
	})

	var result []Branch
	for i := range branches {
		var parsed []string = strings.Split(branches[i], "\trefs/heads/")

		if len(parsed) > 1 {
			result = append(result, Branch{
				Hash: parsed[0],
				Name: parsed[1],
			})
		}
	}

	return result, nil
}

func GetBranchAndAuthors(user string) ([]BranchAuthor, error) {
	const divider = "--X--X--"

	output, err := utils.RunShellCommand("git", []string{
		"for-each-ref",
		"--sort=-committerdate",
		"--format=%(refname:short)" + divider + "%(authorname)" + divider + "%(committerdate:short)",
		"refs/heads/",
	})
	if err != nil {
		return nil, err
	}

	var branchAuthors []BranchAuthor
	lines := strings.Split(strings.TrimSpace(output), "\n")

	for _, line := range lines {
		if line == "" {
			continue
		}

		parts := strings.Split(line, divider)
		if len(parts) < 3 {
			continue
		}

		branchAuthor := BranchAuthor{
			Branch: parts[0],
			Author: parts[1],
			Date:   parts[2],
		}

		if user == "" || strings.Contains(strings.ToLower(branchAuthor.Author), strings.ToLower(user)) {
			branchAuthors = append(branchAuthors, branchAuthor)
		}
	}

	sort.Slice(branchAuthors, func(i, j int) bool {
		return branchAuthors[i].Date > branchAuthors[j].Date
	})

	return branchAuthors, nil
}

func GetMergedBranches(user string, branchToCheck string) ([]BranchAuthor, error) {
	branchAuthors, err := GetBranchAndAuthors(user)
	if err != nil {
		return nil, err
	}

	mergedBranches := make(map[string]bool)

	for _, branchAuthor := range branchAuthors {
		if branchAuthor.Branch == branchToCheck {
			continue
		}

		output, err := utils.RunShellCommand("git", []string{
			"branch",
			"-r",
			"--contains",
			branchAuthor.Branch,
		})
		if err != nil {
			return nil, err
		}

		branches := strings.Split(strings.TrimSpace(output), "\n")
		for _, branch := range branches {
			branch = strings.TrimSpace(branch)
			if strings.Contains(branch, branchToCheck) {
				mergedBranches[branchAuthor.Branch] = true
				break
			}
		}
	}

	var result []BranchAuthor
	for _, branchAuthor := range branchAuthors {
		if merged, exists := mergedBranches[branchAuthor.Branch]; exists && merged {
			result = append(result, branchAuthor)
		}
	}

	return result, nil
}
