package main

import (
	"archive/zip"
	"log"
	"os"
	"path/filepath"

	"github.com/pelletier/go-toml/v2"
)

type pluginCfg struct {
	Plugin struct {
		Author      string   `toml:"author"`
		Description string   `toml:"description"`
		Classifiers []string `toml:"classifiers"`
		License     string   `toml:"license"`
		Keywords    []string `toml:"keywords"`
		Name        string   `toml:"name"`
		Repository  string   `toml:"repository"`
		Script      string   `toml:"script"`
		Version     string   `toml:"version"`

		Dependencies struct {
			Godot string `toml:"godot"`
		} `toml:"dependencies"`
	} `toml:"plugin"`
}

type addon struct {
	addonId     string
	projectPath string
}

func newAddon(name string, projectPath string) *addon {
	return &addon{
		addonId:     name,
		projectPath: projectPath,
	}
}

func (addon *addon) Id() string {
	return addon.addonId
}

func (addon *addon) ProjectPath() string {
	return addon.projectPath
}

func (addon *addon) Path() string {
	return filepath.Join(addon.projectPath, "addons", addon.Id())
}

func (addon *addon) PluginCfgPath() string {
	return filepath.Join(addon.Path(), "plugin.cfg")
}

func (addon *addon) Zip(outputFile string) error {
	err := os.MkdirAll(filepath.Dir(outputFile), os.ModePerm)
	if err != nil {
		log.Fatalln(err)
	}
	file, err := os.Create(outputFile)
	if err != nil {
		return err
	}
	defer file.Close()

	zw := zip.NewWriter(file)
	defer zw.Close()

	// copy files
	err = zipDir(zw, addon.Path(), filepath.Join("addons", addon.Id()))
	if err != nil {
		return err
	}
	exampleDir := filepath.Join(addon.ProjectPath(), "examples", addon.Id())
	// zip example directory only if it exists
	if _, err := os.Stat(exampleDir); err == nil {
		err = zipDir(zw, exampleDir, filepath.Join("examples", addon.Id()))
		if err != nil {
			return err
		}
	}

	err = zipFile(zw, filepath.Join(addon.ProjectPath(), "LICENSE.md"), filepath.Join("addons", addon.Id(), "LICENSE.md"))
	if err != nil {
		return err
	}
	err = zipFile(zw, filepath.Join(addon.ProjectPath(), "README.md"), filepath.Join("examples", addon.Id(), "README.md"))
	if err != nil {
		return err
	}

	return nil
}

func (addon *addon) GetPluginCfg() (*pluginCfg, error) {
	dat, err := os.ReadFile(addon.PluginCfgPath())
	if err != nil {
		return nil, err
	}
	tmp := &pluginCfg{}
	err = toml.Unmarshal(dat, tmp)
	if err != nil {
		return nil, err
	}

	return tmp, nil
}
