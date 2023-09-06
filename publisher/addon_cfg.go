package main

import (
	"archive/zip"
	"os"
	"path/filepath"
	"strings"

	"github.com/pelletier/go-toml/v2"
)

type addonConfig struct {
	addonId     string
	projectPath string
}

func newAddonConfig(name string, projectPath string) *addonConfig {
	return &addonConfig{
		addonId:     name,
		projectPath: projectPath,
	}
}

func (addon *addonConfig) Id() string {
	return addon.addonId
}

func (addon *addonConfig) ProjectPath() string {
	return addon.projectPath
}

func (addon *addonConfig) Path() string {
	return filepath.Join(addon.projectPath, "addons", addon.Id())
}

func (addon *addonConfig) PluginCfgPath() string {
	return filepath.Join(addon.Path(), "plugin.cfg")
}

func (addon *addonConfig) Zip() error {
	exampleDir := filepath.Join(addon.ProjectPath(), "examples", addon.Id())

	version, err := addon.GetVersion()
	if err != nil {
		return err
	}

	destZip := filepath.Join(addon.ProjectPath(), "archives", addon.Id()+"-"+strings.ReplaceAll(version, ".", "_")+".zip")

	file, err := os.Create(destZip)
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
	err = zipDir(zw, exampleDir, filepath.Join("examples", addon.Id()))
	if err != nil {
		return err
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

func (addon *addonConfig) GetVersion() (string, error) {
	dat, err := os.ReadFile(addon.PluginCfgPath())
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
