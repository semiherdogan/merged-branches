package main

import (
	"time"

	"github.com/briandowns/spinner"
)

var spin = spinner.New(spinner.CharSets[14], 80*time.Millisecond)

func SpinnerStart() {
	spin.Color("green", "bold")
	spin.Start()
}

func SpinnerStop() {
	spin.Stop()
}

func SpinnerUpdate(s string) {
	spin.Suffix = " " + s
}
