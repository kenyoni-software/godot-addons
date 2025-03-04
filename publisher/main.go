package main

import (
	"fmt"
	"os"
)

func main() {
	err := newCli().Execute()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
