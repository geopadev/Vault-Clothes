/// Interface for all database interactions.
/// This abstraction allows us to mock the database for testing or switch implementations.
abstract class DatabaseConnector {
  /// Retrieves a document by [collection] and [id].
  Future<Map<String, dynamic>?> getDocument(String collection, String id);

  /// Saves data to a [collection] with a specific [id].
  Future<void> saveDocument(String collection, String id, Map<String, dynamic> data);

  /// Adds a new document to [collection] with an auto-generated ID.
  Future<String> addDocument(String collection, Map<String, dynamic> data);

  /// Updates a document in [collection] by [id].
  Future<void> updateDocument(String collection, String id, Map<String, dynamic> data);

  /// Deletes a document from [collection] by [id].
  Future<void> deleteDocument(String collection, String id);

  /// Returns a stream of a collection matching [query] parameters.
  Stream<List<Map<String, dynamic>>> collectionStream(String collection, {
    String? orderBy,
    bool descending = false,
    int? limit,
  });
}
