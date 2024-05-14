package internal

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
)

type AssetLibraryClient struct {
	httpClient *http.Client

	host  string
	token string
}

func NewAssetLibraryClient(host string) *AssetLibraryClient {
	return &AssetLibraryClient{
		httpClient: &http.Client{},
		host:       host,
	}
}

func (al *AssetLibraryClient) Login(username string, password string) error {
	body, err := json.Marshal(struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}{
		Username: username,
		Password: password,
	})
	if err != nil {
		return err
	}
	resp, err := al.httpClient.Post(al.host+"/login", "application/json", bytes.NewBuffer(body))
	if err != nil {
		return err
	}
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("login: HTTP %d", resp.StatusCode)
	}
	respObj := &struct {
		Authenticated bool   `json:"authenticated"`
		Username      string `json:"username"`
		Token         string `json:"token"`
		Url           string `json:"url"`
	}{}
	err = json.NewDecoder(resp.Body).Decode(respObj)
	if err != nil {
		return err
	}
	if !respObj.Authenticated {
		return fmt.Errorf("login: Authentication Failed")
	}
	al.token = respObj.Token
	return nil
}

func (al *AssetLibraryClient) Logout() error {
	body, err := json.Marshal(struct {
		Token string `json:"token"`
	}{
		Token: al.token,
	})
	if err != nil {
		return err
	}
	resp, err := al.httpClient.Post(al.host+"/logout", "application/json", bytes.NewBuffer(body))
	if err != nil {
		return err
	}
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("logout: %d", resp.StatusCode)
	}
	respObj := &struct {
		Authenticated bool   `json:"authenticated"`
		Token         string `json:"token"`
	}{}
	err = json.NewDecoder(resp.Body).Decode(respObj)
	if err != nil {
		return err
	}
	if respObj.Authenticated {
		return fmt.Errorf("logout failed")
	}
	al.token = ""
	return nil
}

const (
	Cat2DTools   = "1"
	Cat3DTools   = "2"
	CatShaders   = "3"
	CatMaterials = "4"
	CatTools     = "5"
	CatScripts   = "6"
	CatMisc      = "7"
	CatTemplates = "8"
	CatProjects  = "9"
	CatDemos     = "10"
)

type AssetPreview struct {
	PreviewId string `json:"preview_id,omitempty"`
	Type      string `json:"type,omitempty"`
	Link      string `json:"link,omitempty"`
	Thumbnail string `json:"thumbnail,omitempty"`
}

type AssetData struct {
	AssetId          string         `json:"asset_id,omitempty"`
	Type             string         `json:"type,omitempty"`
	Author           string         `json:"author,omitempty"`
	AuthorId         string         `json:"author_id,omitempty"`
	Category         string         `json:"category,omitempty"`
	CategoryId       string         `json:"category_id,omitempty"`
	DownloadProvider string         `json:"download_provider,omitempty"`
	DownloadCommit   string         `json:"download_commit,omitempty"`
	DownloadHash     string         `json:"download_hash,omitempty"`
	License          string         `json:"cost,omitempty"`
	GodotVersion     string         `json:"godot_version,omitempty"`
	IconUrl          string         `json:"icon_url,omitempty"`
	IsArchived       bool           `json:"is_archived,omitempty"`
	IssuesUrl        string         `json:"issues_url,omitempty"`
	ModifyData       string         `json:"modify_data,omitempty"`
	Rating           string         `json:"rating,omitempty"`
	SupportLevel     string         `json:"support_level,omitempty"`
	Title            string         `json:"title,omitempty"`
	Version          string         `json:"version,omitempty"`
	VersionString    string         `json:"version_string,omitempty"`
	Searchable       string         `json:"searchable,omitempty"`
	Previews         []AssetPreview `json:"previews,omitempty"`
	BrowseUrl        string         `json:"browse_url,omitempty"`
	Description      string         `json:"description,omitempty"`
	DownloadUrl      string         `json:"download_url,omitempty"`
}

func (al *AssetLibraryClient) CreateAsset(data AssetData) error {
	body, err := json.Marshal(struct {
		AssetData
		Token string `json:"token"`
	}{
		AssetData: data,
		Token:     al.token,
	})
	if err != nil {
		return err
	}
	resp, err := al.httpClient.Post(fmt.Sprintf("%s/asset", al.host), "application/json", bytes.NewBuffer(body))
	if err != nil {
		return err
	}
	if resp.StatusCode != http.StatusOK {
		all, err := io.ReadAll(resp.Body)
		if err != nil {
			return err
		}
		return fmt.Errorf("update asset (%d): %s", resp.StatusCode, string(all))
	}
	all, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	log.Println(string(all))
	return nil
}

func (al *AssetLibraryClient) UpdateAsset(data AssetData) error {
	body, err := json.Marshal(struct {
		AssetData
		Token string `json:"token"`
	}{
		AssetData: data,
		Token:     al.token,
	})
	if err != nil {
		return err
	}
	resp, err := al.httpClient.Post(fmt.Sprintf("%s/asset/%s", al.host, data.AssetId), "application/json", bytes.NewBuffer(body))
	if err != nil {
		return err
	}
	if resp.StatusCode != http.StatusOK {
		all, err := io.ReadAll(resp.Body)
		if err != nil {
			return err
		}
		return fmt.Errorf("update asset (%d): %s", resp.StatusCode, string(all))
	}
	all, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	log.Println(string(all))
	return nil
}

func (al *AssetLibraryClient) UpdateAssetEdit(editId string, data AssetData) error {
	body, err := json.Marshal(struct {
		AssetData
		Token string `json:"token"`
	}{
		AssetData: data,
		Token:     al.token,
	})
	if err != nil {
		return err
	}
	resp, err := al.httpClient.Post(fmt.Sprintf("%s/asset/edit/%s", al.host, editId), "application/json", bytes.NewBuffer(body))
	if err != nil {
		return err
	}
	if resp.StatusCode != http.StatusOK {
		all, err := io.ReadAll(resp.Body)
		if err != nil {
			return err
		}
		return fmt.Errorf("update asset edit (%d): %s", resp.StatusCode, string(all))
	}
	all, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	log.Println(string(all))
	return nil
}

type AssetEdit struct {
	EditId           string      `json:"edit_id"`
	AssetId          string      `json:"asset_id"`
	UserId           string      `json:"user_id"`
	Title            interface{} `json:"title"`
	Description      interface{} `json:"description"`
	CategoryId       interface{} `json:"category_id"`
	GodotVersion     interface{} `json:"godot_version"`
	VersionString    interface{} `json:"version_string"`
	Cost             interface{} `json:"cost"`
	DownloadProvider interface{} `json:"download_provider"`
	DownloadCommit   interface{} `json:"download_commit"`
	BrowseUrl        string      `json:"browse_url"`
	IssuesUrl        string      `json:"issues_url"`
	IconUrl          interface{} `json:"icon_url"`
	DownloadUrl      string      `json:"download_url"`
	Author           string      `json:"author"`
	Previews         []struct {
		Operation     string  `json:"operation,omitempty"`
		EditPreviewId string  `json:"edit_preview_id,omitempty"`
		PreviewId     *string `json:"preview_id"`
		Type          string  `json:"type"`
		Link          string  `json:"link"`
		Thumbnail     string  `json:"thumbnail"`
	} `json:"previews"`
	Original AssetData `json:"original"`
	Status   string    `json:"status"`
	Reason   string    `json:"reason"`
	Warning  string    `json:"warning"`
}

func (al *AssetLibraryClient) GetAssetEdit(editId string) (*AssetEdit, error) {
	resp, err := al.httpClient.Get(fmt.Sprintf("%s/asset/edit/%s", al.host, editId))
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("get asset edit: %d", resp.StatusCode)
	}

	assetEdit := &AssetEdit{}
	err = json.NewDecoder(resp.Body).Decode(assetEdit)
	if err != nil {
		return nil, err
	}
	return assetEdit, nil
}

func (al *AssetLibraryClient) MoveToReview(assetId string) error {
	body, err := json.Marshal(struct {
		Token string `json:"token"`
	}{
		Token: al.token,
	})
	if err != nil {
		return err
	}
	resp, err := al.httpClient.Post(fmt.Sprintf("%s/asset/edit/%s/review", al.host, assetId), "application/json", bytes.NewBuffer(body))
	if err != nil {
		return err
	}
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("move to review: HTTP %d", resp.StatusCode)
	}
	return nil
}

func (al *AssetLibraryClient) AcceptReview(assetId string) error {
	body, err := json.Marshal(struct {
		Token string `json:"token"`
	}{
		Token: al.token,
	})
	if err != nil {
		return err
	}
	resp, err := al.httpClient.Post(fmt.Sprintf("%s/asset/edit/%s/accept", al.host, assetId), "application/json", bytes.NewBuffer(body))
	if err != nil {
		return err
	}
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("move to review: HTTP %d", resp.StatusCode)
	}
	return nil
}
