package main

import (
	"archive/zip"
	"flag"
	"io"
	"io/fs"
	"log"
	"os"
	"path/filepath"
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
	destDir := filepath.Join(baseDir, "release", addonName+".zip")

	file, err := os.Create(destDir)
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

func zipDir(zw *zip.Writer, src string, dest string) error {
	return filepath.WalkDir(src, func(path string, d fs.DirEntry, err error) error {
		if d.IsDir() {
			return nil
		}
		rel, _ := filepath.Rel(src, path)
		zipFile(zw, path, filepath.Join(dest, rel))
		return nil
	})
}

func zipFile(zw *zip.Writer, src string, dest string) error {
	file, err := os.Open(src)
	if err != nil {
		return err
	}
	defer file.Close()
	zf, err := zw.Create(dest)
	if err != nil {
		return err
	}

	_, err = io.Copy(zf, file)
	return err
}
