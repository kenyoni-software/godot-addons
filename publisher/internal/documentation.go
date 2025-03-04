package internal

import (
	"os"
	"regexp"
	"strings"
)

var (
	rxChangelogPart = regexp.MustCompile(`(?mU)## Changelog\n\n((?s:.)+)(?:\n## |\z)`)
	versionPart     = regexp.MustCompile(`(?m)(?:### (\d+\.\d+\.\d+)\n\n((?:-.*(?:\n|\z))+))`)
)

func GetChangelog(addon *Addon, version string) (string, error) {
	data, err := os.ReadFile(addon.DocPath())
	if err != nil {
		return "", err
	}
	changelog := rxChangelogPart.FindSubmatch(data)
	if len(changelog) == 0 {
		return "", nil
	}

	versions := versionPart.FindAllStringSubmatch(string(changelog[1]), -1)
	for _, v := range versions {
		if v[1] == version {
			return strings.Trim(v[2], " \n"), nil
		}
	}
	return "", nil
}
