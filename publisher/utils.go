package main

import (
	"archive/zip"
	"io"
	"io/fs"
	"os"
	"path/filepath"
)

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
