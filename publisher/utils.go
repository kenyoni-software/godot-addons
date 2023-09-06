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
		rel, _ := filepath.Rel(src, path)
		destPath := filepath.Join(dest, rel)
		if d.IsDir() {
			_, err := zw.Create(destPath + "/")
			return err
		}
		return zipFile(zw, path, destPath)
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

func contains[T comparable](elems []T, v T) bool {
	for _, s := range elems {
		if v == s {
			return true
		}
	}
	return false
}
