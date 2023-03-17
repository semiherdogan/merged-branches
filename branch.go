package main

import (
	"fmt"
	"sort"
	"strings"
	"time"
)

type Branch struct {
	branch string
	hash   string
}

type BranchAuthor struct {
	author string
	branch string
	date   string
}

func GetBranches(branchToCheck string) (branchesResult []Branch) {
	//Getting remote branch list...
	var output, _ = RunShellCommand("git", []string{"ls-remote"})

	var branches []string = Filter(strings.Split(output, "\n"), func(s string) bool {
		return len(s) > 0 &&
			!strings.Contains(s, "HEAD") &&
			!strings.Contains(s, "refs/tags/") &&
			!strings.Contains(s, "refs/heads/"+branchToCheck) &&
			!strings.Contains(s, "From ")
	})

	for i := range branches {
		var parsed []string = strings.Split(branches[i], "\trefs/heads/")

		if len(parsed) > 1 {
			branchesResult = append(branchesResult, Branch{
				hash:   parsed[0],
				branch: parsed[1],
			})
		}
	}

	return
}

func GetBranchAndAuthors(user string) (branchAuthors []BranchAuthor) {
	const divider string = "--X--X--"

	// Getting branch and author info...
	output, _ := RunShellCommand("git", []string{
		"for-each-ref",
		fmt.Sprintf("--format=%%(authorname)%s%%(refname:strip=3)%s%%(committerdate)", divider, divider),
		"--sort=committerdate",
		"refs/remotes",
	})

	var branchAuthorList []string = Filter(strings.Split(output, "\n"), func(s string) bool {
		return len(s) > 0
	})

	for _, branchAuthor := range branchAuthorList {
		var row []string = strings.Split(branchAuthor, divider)

		if user == "" || strings.Contains(strings.ToLower(row[0]), strings.ToLower(user)) {
			t, _ := time.Parse("Mon Jan 2 15:04:05 2006 -0700", row[2])
			branchAuthors = append(branchAuthors, BranchAuthor{
				author: row[0],
				branch: row[1],
				date:   t.Format("2006-01-02 15:04:05"),
			})
		}
	}

	return
}

func GetMergedBranches(user string, branchToCheck string) (branchAuthorResult []BranchAuthor) {
	SpinnerUpdate("Getting branch and author info...")
	var branchAuthors []BranchAuthor = GetBranchAndAuthors(user)

	SpinnerUpdate("Getting remote branch list...")
	var branches = GetBranches(branchToCheck)

	SpinnerUpdate("Checking branches and commits...")
	for _, branch := range branches {
		var output, _ = RunShellCommand("git", []string{"branch", "-r", "--contains", branch.hash})

		var branchExistsInMergedList []string = Filter(strings.Split(output, "\n"), func(s string) bool {
			return len(s) > 0 && !strings.Contains(s, "HEAD")
		})

		branchExistsInMergedList = Map(branchExistsInMergedList, func(s string) string {
			return strings.TrimSpace(s)
		})

		if len(branchExistsInMergedList) > 0 && Contains(branchExistsInMergedList, "origin/"+branchToCheck) {
			for _, branchAuthor := range branchAuthors {
				if branchAuthor.branch == branch.branch {
					branchAuthorResult = append(branchAuthorResult, branchAuthor)
					break
				}
			}
		}
	}

	// sort list by date
	sort.Slice(branchAuthorResult, func(i, j int) bool {
		return branchAuthorResult[i].date > branchAuthorResult[j].date
	})

	return
}
