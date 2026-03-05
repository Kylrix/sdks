import { Kylrix } from './index';

/**
 * Kylrix.Note: The Intelligence Layer Module.
 * Domain: note.kylrix.space
 */
export class KylrixNote {
  constructor(private sdk: Kylrix) {}

  /**
   * Saves a note revision with optional metadata.
   */
  async saveRevision(databaseId: string, tableId: string, data: {
    noteId: string;
    userId: string;
    content: string;
    title?: string;
    diff?: string;
    cause?: 'manual' | 'ai' | 'collab';
  }) {
    return await this.sdk.createRow(databaseId, tableId, {
      ...data,
      createdAt: new Date().toISOString(),
      cause: data.cause || 'manual',
    });
  }

  /**
   * Adds a tag to a note.
   */
  async addTag(databaseId: string, tableId: string, noteId: string, tagName: string) {
    const note = await this.sdk.getRow<any>(databaseId, tableId, noteId);
    const tags = new Set(note.tags || []);
    tags.add(tagName);
    
    return await this.sdk.updateRow(databaseId, tableId, noteId, {
      tags: Array.from(tags),
    });
  }

  /**
   * Lists notes for a specific user.
   */
  async listNotes(databaseId: string, tableId: string, userId: string) {
    return await this.sdk.listRows<any>(databaseId, tableId, [
      `equal("userId", "${userId}")`
    ]);
  }
}
