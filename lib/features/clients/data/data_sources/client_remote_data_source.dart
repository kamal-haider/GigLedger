import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../dto/client_dto.dart';

/// Remote data source for client operations
abstract class ClientRemoteDataSource {
  /// Get all clients for current user
  Future<List<ClientDTO>> getAll();

  /// Get client by ID
  Future<ClientDTO?> getById(String id);

  /// Watch all clients (real-time)
  Stream<List<ClientDTO>> watchAll();

  /// Watch single client
  Stream<ClientDTO?> watch(String id);

  /// Create client
  Future<ClientDTO> create(ClientDTO client);

  /// Update client
  Future<ClientDTO> update(ClientDTO client);

  /// Delete client
  Future<void> delete(String id);

  /// Get client count
  Future<int> getCount();

  /// Update client totals
  Future<void> updateTotals(String clientId, {double? billed, double? paid});
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  ClientRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  String get _userId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated', code: 'not-authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _clientsCollection =>
      _firestore.collection('users').doc(_userId).collection('clients');

  @override
  Future<List<ClientDTO>> getAll() async {
    try {
      final snapshot = await _clientsCollection.orderBy('name').get();
      return snapshot.docs
          .map((doc) => ClientDTO.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get clients: $e', code: 'firestore-read-error');
    }
  }

  @override
  Future<ClientDTO?> getById(String id) async {
    try {
      final doc = await _clientsCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return ClientDTO.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Failed to get client: $e', code: 'firestore-read-error');
    }
  }

  @override
  Stream<List<ClientDTO>> watchAll() {
    return _clientsCollection.orderBy('name').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ClientDTO.fromJson(doc.data(), doc.id)).toList());
  }

  @override
  Stream<ClientDTO?> watch(String id) {
    return _clientsCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return ClientDTO.fromJson(doc.data()!, doc.id);
    });
  }

  @override
  Future<ClientDTO> create(ClientDTO client) async {
    try {
      final now = Timestamp.now();
      final data = client.toJson()
        ..['userId'] = _userId
        ..['createdAt'] = now
        ..['updatedAt'] = now
        ..['totalBilled'] = 0
        ..['totalPaid'] = 0;

      final docRef = await _clientsCollection.add(data);
      final doc = await docRef.get();
      return ClientDTO.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Failed to create client: $e', code: 'firestore-write-error');
    }
  }

  @override
  Future<ClientDTO> update(ClientDTO client) async {
    try {
      final data = client.toJson()..['updatedAt'] = Timestamp.now();
      data.remove('createdAt');

      await _clientsCollection.doc(client.id).update(data);
      final doc = await _clientsCollection.doc(client.id).get();
      return ClientDTO.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Failed to update client: $e', code: 'firestore-write-error');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _clientsCollection.doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete client: $e', code: 'firestore-write-error');
    }
  }

  @override
  Future<int> getCount() async {
    try {
      final snapshot = await _clientsCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw ServerException('Failed to get client count: $e', code: 'firestore-read-error');
    }
  }

  @override
  Future<void> updateTotals(String clientId, {double? billed, double? paid}) async {
    try {
      final updates = <String, dynamic>{'updatedAt': Timestamp.now()};
      if (billed != null) updates['totalBilled'] = FieldValue.increment(billed);
      if (paid != null) updates['totalPaid'] = FieldValue.increment(paid);

      await _clientsCollection.doc(clientId).update(updates);
    } catch (e) {
      throw ServerException('Failed to update totals: $e', code: 'firestore-write-error');
    }
  }
}
