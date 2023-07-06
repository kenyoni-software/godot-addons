package main

import (
	"flag"
	"log"
	"os"
)

const (
	actionZip     = "zip"
	actionVersion = "version"
)

type cmdParser struct {
	fs        *flag.FlagSet
	Action    string
	Directory string
	Addons    []string
}

// Parse might exit the program
func (cp *cmdParser) Parse(arguments []string) {
	err := cp.fs.Parse(arguments)
	if err != nil {
		log.Fatalln(err)
	}

	if cp.fs.NArg() < 2 {
		cp.fs.Usage()
		log.Fatalln()
	}
	cp.Action = cp.fs.Arg(0)
	if cp.Action != actionVersion && cp.Action != actionZip {
		cp.fs.Usage()
		log.Fatalln()
	}
	cp.Directory = cp.fs.Arg(1)
	cp.Addons = cp.fs.Args()[2:]
	if cp.Action == actionZip && len(cp.Addons) != 1 {
		cp.fs.Usage()
		log.Fatalln()
	}
}

func newCmdParser() *cmdParser {
	cp := cmdParser{
		fs: flag.NewFlagSet(os.Args[0], flag.ExitOnError),
	}
	return &cp
}
