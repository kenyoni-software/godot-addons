package main

import (
	"archive/zip"
	"flag"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/pelletier/go-toml/v2"
)

func main() {
	flagSet := flag.NewFlagSet(os.Args[0], flag.ExitOnError)
	err := flagSet.Parse(os.Args[1:])
	if err != nil {
		log.Fatalln(err)
	}
	if flagSet.NArg() != 1 {
		log.Fatalln("wrong arguments")
	}

	iterDirectories(flagSet.Arg(0))
}

func iterDirectories(baseDir string) {
	err := os.MkdirAll(filepath.Join(baseDir, "release"), os.ModePerm)
	if err != nil {
		log.Fatalln(err)
	}

	dirs, err := os.ReadDir(filepath.Join(baseDir, "addons"))
	if err != nil {
		log.Fatalln(err)
	}
	for _, dir := range dirs {
		if !dir.IsDir() {
			continue
		}
		err = prepareAddon(baseDir, dir.Name())
		if err != nil {
			log.Fatalln(err)
		}
	}
}

func prepareAddon(baseDir string, addonName string) error {
	addonDir := filepath.Join(baseDir, "addons", addonName)
	exampleDir := filepath.Join(baseDir, "examples", addonName)

	version, err := getAddonVersion(filepath.Join(addonDir, "plugin.cfg"))
	if err != nil {
		return err
	}

	destZip := filepath.Join(baseDir, "release", addonName+"-"+strings.ReplaceAll(version, ".", "_")+".zip")

	file, err := os.Create(destZip)
	if err != nil {
		return err
	}
	defer file.Close()

	zw := zip.NewWriter(file)
	defer zw.Close()

	// copy files
	err = zipDir(zw, addonDir, filepath.Join("addons", addonName))
	if err != nil {
		return err
	}
	err = zipDir(zw, exampleDir, "example")
	if err != nil {
		return err
	}

	for _, val := range []string{
		".gitignore",
		"LICENSE.md",
		"README.md",
	} {
		err = zipFile(zw, filepath.Join(baseDir, val), val)
		if err != nil {
			return err
		}
	}

	return nil
}

func getAddonVersion(cfgPath string) (string, error) {
	dat, err := os.ReadFile(cfgPath)
	if err != nil {
		return "", err
	}
	tmp := struct {
		Plugin struct {
			Version string `toml:"version"`
		} `toml:"plugin"`
	}{}
	err = toml.Unmarshal(dat, &tmp)
	if err != nil {
		return "", err
	}

	return tmp.Plugin.Version, nil
}
