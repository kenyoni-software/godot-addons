package internal

import (
	"archive/zip"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/pelletier/go-toml/v2"
)

type PluginCfg struct {
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

type Addon struct {
	addonID     string
	projectPath string
}

func NewAddon(id string, projectPath string) *Addon {
	return &Addon{
		addonID:     id,
		projectPath: projectPath,
	}
}

// ID contains the namespace directory and the addon directory name like "kenyoni/addon_name"
func (addon *Addon) ID() string {
	return addon.addonID
}

// IDName is only the addon directory name like "addon_name"
func (addon *Addon) IDName() string {
	split := strings.Split(addon.addonID, "/")
	return split[len(split)-1]
}

func (addon *Addon) ProjectPath() string {
	return addon.projectPath
}

func (addon *Addon) Path() string {
	return filepath.Join(addon.projectPath, "addons", addon.ID())
}

func (addon *Addon) DocPath() string {
	return filepath.Join(addon.projectPath, "doc", "docs", "addons", addon.IDName()+".md")
}

func (addon *Addon) PluginCfgPath() string {
	return filepath.Join(addon.Path(), "plugin.cfg")
}

func (addon *Addon) Zip(outputFile string) error {
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
	err = ZipDir(zw, addon.Path(), filepath.Join("addons", addon.ID()))
	if err != nil {
		return err
	}
	exampleDir := filepath.Join(addon.ProjectPath(), "examples", addon.IDName())
	// zip example directory only if it exists
	if _, err := os.Stat(exampleDir); err == nil {
		err = ZipDir(zw, exampleDir, filepath.Join("examples", addon.ID()))
		if err != nil {
			return err
		}
	}

	err = ZipFile(zw, filepath.Join(addon.ProjectPath(), "LICENSE.md"), filepath.Join("addons", addon.ID(), "LICENSE.md"))
	if err != nil {
		return err
	}
	err = ZipFile(zw, filepath.Join(addon.ProjectPath(), "README.md"), filepath.Join("examples", addon.ID(), "README.md"))
	if err != nil {
		return err
	}

	return nil
}

func (addon *Addon) GetPluginCfg() (*PluginCfg, error) {
	dat, err := os.ReadFile(addon.PluginCfgPath())
	if err != nil {
		return nil, err
	}
	tmp := &PluginCfg{}
	err = toml.Unmarshal(dat, tmp)
	if err != nil {
		return nil, err
	}

	return tmp, nil
}
