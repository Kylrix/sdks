package kylrix

import (
	"fmt"
	"strings"

	"github.com/appwrite/sdk-for-go/appwrite"
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
	Appwrite  client.Client
	Account   *appwrite.Account
	Databases *databases.Databases
}

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

	return &Client{
		Appwrite:  c,
		Account:   appwrite.NewAccount(c),
		Databases: databases.New(c),
	}
}

// ListRows maps to Appwrite ListDocuments
func (c *Client) ListRows(databaseId string, tableId string, queries []interface{}) (*models.DocumentList, error) {
	// Note: queries usually need to be cast to databases.ListDocumentsOption
	// This is a simplified wrapper for now
	return c.Databases.ListDocuments(databaseId, tableId)
}

// GetRow maps to Appwrite GetDocument
func (c *Client) GetRow(databaseId string, tableId string, rowId string) (*models.Document, error) {
	return c.Databases.GetDocument(databaseId, tableId, rowId)
}

// CreateRow maps to Appwrite CreateDocument
func (c *Client) CreateRow(databaseId string, tableId string, rowId string, data interface{}) (*models.Document, error) {
	if rowId == "" || rowId == "unique()" {
		rowId = id.Unique()
	}
	return c.Databases.CreateDocument(databaseId, tableId, rowId, data)
}

// UpdateRow maps to Appwrite UpdateDocument
func (c *Client) UpdateRow(databaseId string, tableId string, rowId string, data interface{}) (*models.Document, error) {
	return c.Databases.UpdateDocument(databaseId, tableId, rowId, databases.WithUpdateDocumentData(data))
}

// DeleteRow maps to Appwrite DeleteDocument
func (c *Client) DeleteRow(databaseId string, tableId string, rowId string) (interface{}, error) {
	return c.Databases.DeleteDocument(databaseId, tableId, rowId)
}

// GetEventPath returns a standardized Kylrix event path
func GetEventPath(databaseId string, tableId string, rowId string) string {
	if rowId == "" {
		return fmt.Sprintf("databases.%s.tables.%s.rows", databaseId, tableId)
	}
	return fmt.Sprintf("databases.%s.tables.%s.rows.%s", databaseId, tableId, rowId)
}
