package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"slices"
)

func main() {
	cmdP := newCmdParser()
	cmdP.Parse(os.Args[1:])

	var err error
	switch cmdP.Action {
	case actionVersion:
		addonCfg := newAddonConfig(cmdP.Addons[0], cmdP.Directory)
		version, err := addonCfg.GetVersion()
		if err != nil {
			log.Fatalln(err)
		}
		fmt.Println(version)
	case actionZip:
		err = iterDirectories(cmdP.Directory, cmdP.Addons)
	}
	if err != nil {
		log.Fatalln(err)
	}
}

func iterDirectories(baseDir string, addons []string) error {
	err := os.MkdirAll(filepath.Join(baseDir, "archives"), os.ModePerm)
	if err != nil {
		return err
	}

	dirs, err := os.ReadDir(filepath.Join(baseDir, "addons"))
	if err != nil {
		return err
	}
	for _, dir := range dirs {
		if !dir.IsDir() {
			continue
		}
		if len(addons) != 0 && !slices.Contains(addons, dir.Name()) {
			continue
		}
		addonCfg := newAddonConfig(dir.Name(), baseDir)
		err = addonCfg.Zip()
		if err != nil {
			return err
		}
	}
	return nil
}
