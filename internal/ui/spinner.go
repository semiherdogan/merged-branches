// Package ui provides user interface components like spinners and logging
package ui

import (
	"fmt"
	"io"
	"os"
	"time"

	"github.com/briandowns/spinner"
)

const (
	// DefaultSpinnerSpeed is the default speed for the spinner animation
	DefaultSpinnerSpeed = 100 * time.Millisecond
	// DefaultCharSet is the default character set for the spinner
	DefaultCharSet = 11
)

var (
	spinnerObj *spinner.Spinner
	// OutputWriter is where UI output will be written (defaults to os.Stdout)
	OutputWriter io.Writer = os.Stdout
)

// SpinnerStart initializes and starts a new spinner if one isn't already running
func SpinnerStart() {
	if spinnerObj == nil {
		s := spinner.New(
			spinner.CharSets[DefaultCharSet],
			DefaultSpinnerSpeed,
			spinner.WithWriter(OutputWriter),
		)
		spinnerObj = s
		s.Start()
	}
}

// SpinnerStop stops the currently running spinner if one exists
func SpinnerStop() {
	if spinnerObj != nil {
		spinnerObj.Stop()
		spinnerObj = nil
	}
}

// Log prints messages to the output writer, stopping any active spinner first
func Log(message ...interface{}) {
	SpinnerStop()
	fmt.Fprintln(OutputWriter, message...)
}

// Logf prints formatted messages to the output writer, stopping any active spinner first
func Logf(format string, args ...interface{}) {
	SpinnerStop()
	fmt.Fprintf(OutputWriter, format, args...)
}
