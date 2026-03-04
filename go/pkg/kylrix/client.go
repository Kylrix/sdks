package kylrix

import (
	"github.com/appwrite/sdk-for-go/appwrite"
)

// Client represents the Kylrix SDK client
type Client struct {
	Appwrite *appwrite.Client
	Account  *appwrite.Account
	Storage  *appwrite.Storage
}

// Config holds the SDK configuration
type Config struct {
	Endpoint string
	Project  string
}

// NewClient creates a new instance of the Kylrix SDK client
func NewClient(config Config) *Client {
	c := appwrite.NewClient()
	c.SetEndpoint(config.Endpoint)
	c.SetProject(config.Project)

	return &Client{
		Appwrite: c,
		Account:  appwrite.NewAccount(c),
		Storage:  appwrite.NewStorage(c),
	}
}
