import { Client, Account, Databases, ID, Query, Realtime } from 'appwrite';
import { KylrixSecurity } from './security';
import { getEcosystemUrl, ECOSYSTEM_CONFIG, TABLE_DB } from './ecosystem';
import { KylrixPulse } from './pulse';

/**
 * Kylrix SDK Configuration
 */
export interface KylrixConfig {
  endpoint: string;
  project: string;
}

/**
 * The official Kylrix SDK for interacting with the private ecosystem.
 */
export class Kylrix {
  private client: Client;
  public account: Account;
  private databases: Databases;
  private realtimeInstance: Realtime | null = null;
  private pulseInstance: KylrixPulse | null = null;

  // Security layer
  public security = KylrixSecurity;

  // Ecosystem configuration
  public config = ECOSYSTEM_CONFIG;
  public resolveUrl = getEcosystemUrl;
  public tableDb = TABLE_DB;

  constructor(config: KylrixConfig) {
    this.client = new Client()
      .setEndpoint(config.endpoint)
      .setProject(config.project);
    
    this.account = new Account(this.client);
    this.databases = new Databases(this.client);
  }

  /**
   * Initializes and returns the Realtime instance.
   */
  get realtime(): Realtime {
    if (!this.realtimeInstance) {
      this.realtimeInstance = new Realtime(this.client);
    }
    return this.realtimeInstance;
  }

  /**
   * High-level Pulse Orchestrator for ecosystem gossip.
   */
  get pulse(): KylrixPulse {
    if (!this.pulseInstance) {
      this.pulseInstance = new KylrixPulse(this.realtime);
    }
    return this.pulseInstance;
  }


  /**
   * Standardized listRows (formerly listDocuments)
   */
  async listRows(databaseId: string, tableId: string, queries: string[] = []) {
    return await this.databases.listDocuments(databaseId, tableId, queries);
  }

  /**
   * Standardized getRow (formerly getDocument)
   */
  async getRow(databaseId: string, tableId: string, rowId: string) {
    return await this.databases.getDocument(databaseId, tableId, rowId);
  }

  /**
   * Standardized createRow (formerly createDocument)
   */
  async createRow(databaseId: string, tableId: string, data: any, rowId: string = ID.unique()) {
    return await this.databases.createDocument(databaseId, tableId, rowId, data);
  }
}

