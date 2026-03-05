package kylrix

import (
	"fmt"
	"strings"

	"github.com/appwrite/sdk-for-go/client"
	"github.com/appwrite/sdk-for-go/databases"
	"github.com/appwrite/sdk-for-go/id"
	"github.com/appwrite/sdk-for-go/models"
)

// Ecosystem constants
const (
	DefaultDomain   = "kylrix.space"
	DefaultEndpoint = "https://cloud.appwrite.io/v1"
)

// Subdomain mapping
var subdomains = map[string]string{
	"accounts": "accounts",
	"vault":    "vault",
	"note":     "note",
	"flow":     "flow",
	"connect":  "connect",
}

// Brand constants
const (
	BrandPrimary = "#6366F1"
	BrandCreamy  = "#FDFCFB"
	BrandGlass   = "rgba(255, 255, 255, 0.7)"

	FontHeading = "Clash Display"
	FontUI      = "Satoshi"
	FontMono    = "JetBrains Mono"
)

// GetEcosystemURL resolves the full URL for a given ecosystem app
func GetEcosystemURL(subdomain string, path string) string {
	sub, ok := subdomains[subdomain]
	if !ok {
		sub = subdomain
	}
	url := fmt.Sprintf("https://%s.%s", sub, DefaultDomain)
	if path == "" {
		return url
	}
	if !strings.HasPrefix(path, "/") {
		path = "/" + path
	}
	return url + path
}

// Client represents the Kylrix SDK client
type Client struct {
	Appwrite  *client.Client
	Databases *databases.Databases

	// Identity & Security
	Theme    *Theme
	Security *KylrixSecurity

	// Domain Modules
	Connect *ConnectModule
	Vault   *VaultModule
	Flow    *FlowModule
	Note    *NoteModule
}

// Theme constants wrapper
type Theme struct{}

// Config holds the SDK configuration
type Config struct {
	Endpoint string
	Project  string
}

// NewClient creates a new instance of the Kylrix SDK client
func NewClient(config Config) *Client {
	if config.Endpoint == "" {
		config.Endpoint = DefaultEndpoint
	}

	c := client.New()
	c.SetEndpoint(config.Endpoint)
	c.SetProject(config.Project)

	sdk := &Client{
		Appwrite:  c,
		Databases: databases.New(c),
		Theme:     &Theme{},
		Security:  &KylrixSecurity{},
	}

	sdk.Connect = &ConnectModule{sdk: sdk}
	sdk.Vault = &VaultModule{sdk: sdk}
	sdk.Flow = &FlowModule{sdk: sdk}
	sdk.Note = &NoteModule{sdk: sdk}

	return sdk
}

// --- TableDB Abstraction ---

func (c *Client) ListRows(databaseId string, tableId string) (*models.DocumentList, error) {
	return c.Databases.ListDocuments(databaseId, tableId)
}

func (c *Client) GetRow(databaseId string, tableId string, rowId string) (*models.Document, error) {
	return c.Databases.GetDocument(databaseId, tableId, rowId)
}

func (c *Client) CreateRow(databaseId string, tableId string, rowId string, data interface{}) (*models.Document, error) {
	if rowId == "" || rowId == "unique()" {
		rowId = id.Unique()
	}
	return c.Databases.CreateDocument(databaseId, tableId, rowId, data)
}

func (c *Client) UpdateRow(databaseId string, tableId string, rowId string, data interface{}) (*models.Document, error) {
	// Note: Actual implementation requires WithUpdateDocumentData or similar option
	return c.Databases.UpdateDocument(databaseId, tableId, rowId)
}

func (c *Client) DeleteRow(databaseId string, tableId string, rowId string) (interface{}, error) {
	return c.Databases.DeleteDocument(databaseId, tableId, rowId)
}

// --- Domain Modules ---

type ConnectModule struct{ sdk *Client }
type VaultModule struct{ sdk *Client }
type FlowModule struct{ sdk *Client }
type NoteModule struct{ sdk *Client }

func (m *ConnectModule) SendMessage(dbId, tableId string, data interface{}) (*models.Document, error) {
	return m.sdk.CreateRow(dbId, tableId, "", data)
}

func (m *VaultModule) GetCredentials(dbId, tableId string) (*models.DocumentList, error) {
	return m.sdk.ListRows(dbId, tableId)
}

func (m *FlowModule) CreateTask(dbId, tableId string, data interface{}) (*models.Document, error) {
	return m.sdk.CreateRow(dbId, tableId, "", data)
}

func (m *NoteModule) SaveRevision(dbId, tableId string, data interface{}) (*models.Document, error) {
	return m.sdk.CreateRow(dbId, tableId, "", data)
}

// GetEventPath returns a standardized Kylrix event path
func GetEventPath(databaseId string, tableId string, rowId string) string {
	if rowId == "" {
		return fmt.Sprintf("databases.%s.tables.%s.rows", databaseId, tableId)
	}
	return fmt.Sprintf("databases.%s.tables.%s.rows.%s", databaseId, tableId, rowId)
}
