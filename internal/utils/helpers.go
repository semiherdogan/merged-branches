// Package utils provides common utility functions used throughout the application.
package utils

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"
	"time"
)

// DefaultCommandTimeout is the default timeout for command execution
const DefaultCommandTimeout = 30 * time.Second

// RunShellCommand executes a shell command with the given arguments and returns its output.
// The command will be terminated if it runs longer than DefaultCommandTimeout.
func RunShellCommand(command string, args []string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), DefaultCommandTimeout)
	defer cancel()

	cmd := exec.CommandContext(ctx, command, args...)
	output, err := cmd.CombinedOutput()
	outputStr := strings.TrimSpace(string(output))

	if ctx.Err() == context.DeadlineExceeded {
		return "", fmt.Errorf("command timed out after %v", DefaultCommandTimeout)
	}

	if err != nil {
		return outputStr, fmt.Errorf("command failed: %w\nOutput: %s", err, outputStr)
	}

	return outputStr, nil
}

// Filter returns a new slice containing only the elements of vs that satisfy the predicate f.
// This is a generic-like implementation for string slices.
func Filter(vs []string, f func(string) bool) []string {
	if vs == nil {
		return nil
	}

	filtered := make([]string, 0, len(vs))
	for _, v := range vs {
		if f(v) {
			filtered = append(filtered, v)
		}
	}
	return filtered
}

// Contains checks if a string slice contains the specified item.
// It returns true if the item is found, false otherwise.
func Contains(slice []string, item string) bool {
	if slice == nil {
		return false
	}

	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

// HandleKeyboardInterrupt sets up a signal handler for keyboard interrupts (Ctrl+C)
// and calls the provided handler function when an interrupt is received.
// The handler is only called once, and subsequent interrupts will trigger os.Exit(1).
func HandleKeyboardInterrupt(handler func()) {
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)

	go func() {
		// First signal: call the handler
		<-c
		handler()

		// Second signal: force exit
		<-c
		os.Exit(1)
	}()
}
