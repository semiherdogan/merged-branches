package main

import (
	"fmt"
	"os"
	"os/exec"
	"os/signal"

	"github.com/fatih/color"
	"github.com/mattn/go-runewidth"
	"github.com/rodaine/table"
)

func HandleKeyboardInterrupt(cond func()) {
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)

	go func() {
		<-c
		cond()
	}()
}

func RunShellCommand(path string, args []string) (out string, err error) {
	cmd := exec.Command(path, args...)

	var b []byte
	b, err = cmd.CombinedOutput()
	out = string(b)

	return
}

func Filter[T comparable](arr []T, cond func(T) bool) (result []T) {
	for i := range arr {
		if cond(arr[i]) {
			result = append(result, arr[i])
		}
	}

	return
}

func Map[T comparable, Y comparable](arr []T, cond func(T) Y) (result []Y) {
	for i := range arr {
		result = append(result, cond(arr[i]))
	}

	return
}

func Contains[T comparable](arr []T, e T) bool {
	for _, v := range arr {
		if v == e {
			return true
		}
	}

	return false
}

func Log(a ...any) {
	fmt.Println(a...)
}

func CheckGitFolder(cond func()) {
	_, err := os.Stat(".git/")

	if os.IsNotExist(err) {
		cond()
	}
}

func PrintTable(tbl table.Table) {
	headerFmt := color.New(color.FgGreen, color.Underline).SprintfFunc()
	columnFmt := color.New(color.FgYellow).SprintfFunc()

	tbl.WithHeaderFormatter(headerFmt).WithFirstColumnFormatter(columnFmt)

	tbl.WithWidthFunc(func(s string) int {
		return runewidth.StringWidth(s)
	})

	tbl.Print()
}
