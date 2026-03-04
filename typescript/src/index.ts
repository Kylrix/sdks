import { Client, Account, Databases, ID, Query } from 'appwrite';

/**
 * Kylrix SDK Configuration
 */
export interface KylrixConfig {
  endpoint: string;
  project: string;
  domain?: string;
}

/**
 * The official Kylrix SDK for interacting with the private ecosystem.
 */
export class Kylrix {
  private client: Client;
  public account: Account;
  private databases: Databases;

  constructor(config: KylrixConfig) {
    this.client = new Client()
      .setEndpoint(config.endpoint)
      .setProject(config.project);
    
    this.account = new Account(this.client);
    this.databases = new Databases(this.client);
  }

  /**
   * Helper to get common ecosystem domains if not provided
   */
  static getDomain(subdomain: string, baseDomain: string = 'kylrix.space'): string {
    return `https://${subdomain}.${baseDomain}`;
  }

  // Future implementation of TableDB abstractions
  async listRows(databaseId: string, tableId: string, queries: string[] = []) {
    return await this.databases.listDocuments(databaseId, tableId, queries);
  }

  async getRow(databaseId: string, tableId: string, rowId: string) {
    return await this.databases.getDocument(databaseId, tableId, rowId);
  }
}
