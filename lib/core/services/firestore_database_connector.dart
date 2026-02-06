import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vault_clothes/core/services/database_connector.dart';

class FirestoreDatabaseConnector implements DatabaseConnector {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String id,
  ) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    return doc.data();
  }

  @override
  Future<void> saveDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(id).set(data);
  }

  @override
  Future<String> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final docRef = await _firestore.collection(collection).add(data);
    return docRef.id;
  }

  @override
  Future<void> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(id).update(data);
  }

  @override
  Future<void> deleteDocument(String collection, String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  @override
  Stream<List<Map<String, dynamic>>> collectionStream(
    String collection, {
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }
}
