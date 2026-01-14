import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/models/invoice.dart';
import '../dto/invoice_dto.dart';

/// Remote data source for invoice operations
abstract class InvoiceRemoteDataSource {
  Future<List<InvoiceDTO>> getAll();
  Future<List<InvoiceDTO>> getByStatus(String status);
  Future<List<InvoiceDTO>> getByClientId(String clientId);
  Future<InvoiceDTO?> getById(String id);
  Stream<List<InvoiceDTO>> watchAll();
  Stream<List<InvoiceDTO>> watchByStatus(String status);
  Stream<InvoiceDTO?> watch(String id);
  Future<InvoiceDTO> create(InvoiceDTO invoice);
  Future<InvoiceDTO> update(InvoiceDTO invoice);
  Future<void> delete(String id);
  Future<InvoiceDTO> updateStatus(String id, String status,
      {DateTime? paidDate});
  Future<String> getNextInvoiceNumber();
  Future<int> getCount();
  Future<int> getMonthlyCount();
  Future<List<InvoiceDTO>> getOverdue();
}

class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  InvoiceRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  String get _userId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated',
          code: 'not-authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _invoicesCollection =>
      _firestore.collection('users').doc(_userId).collection('invoices');

  @override
  Future<List<InvoiceDTO>> getAll() async {
    try {
      final snapshot = await _invoicesCollection
          .orderBy('issueDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => InvoiceDTO.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get invoices: $e',
          code: 'firestore-read-error');
    }
  }

  @override
  Future<List<InvoiceDTO>> getByStatus(String status) async {
    try {
      final snapshot = await _invoicesCollection
          .where('status', isEqualTo: status)
          .orderBy('issueDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => InvoiceDTO.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get invoices: $e',
          code: 'firestore-read-error');
    }
  }

  @override
  Future<List<InvoiceDTO>> getByClientId(String clientId) async {
    try {
      final snapshot = await _invoicesCollection
          .where('clientId', isEqualTo: clientId)
          .orderBy('issueDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => InvoiceDTO.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get invoices: $e',
          code: 'firestore-read-error');
    }
  }

  @override
  Future<InvoiceDTO?> getById(String id) async {
    try {
      final doc = await _invoicesCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return InvoiceDTO.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Failed to get invoice: $e',
          code: 'firestore-read-error');
    }
  }

  @override
  Stream<List<InvoiceDTO>> watchAll() {
    return _invoicesCollection
        .orderBy('issueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvoiceDTO.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<List<InvoiceDTO>> watchByStatus(String status) {
    return _invoicesCollection
        .where('status', isEqualTo: status)
        .orderBy('issueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvoiceDTO.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<InvoiceDTO?> watch(String id) {
    return _invoicesCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return InvoiceDTO.fromJson(doc.data()!, doc.id);
    });
  }

  @override
  Future<InvoiceDTO> create(InvoiceDTO invoice) async {
    try {
      final now = Timestamp.now();
      final data = invoice.toJson()
        ..['userId'] = _userId
        ..['createdAt'] = now
        ..['updatedAt'] = now;

      final docRef = await _invoicesCollection.add(data);
      final doc = await docRef.get();
      return InvoiceDTO.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Failed to create invoice: $e',
          code: 'firestore-write-error');
    }
  }

  @override
  Future<InvoiceDTO> update(InvoiceDTO invoice) async {
    try {
      if (invoice.userId != null && invoice.userId != _userId) {
        throw const AuthException(
          'Cannot update invoice belonging to another user',
          code: 'permission-denied',
        );
      }

      final data = invoice.toJson()..['updatedAt'] = Timestamp.now();
      data.remove('createdAt');
      data['userId'] = _userId;

      await _invoicesCollection.doc(invoice.id).update(data);
      final doc = await _invoicesCollection.doc(invoice.id).get();
      return InvoiceDTO.fromJson(doc.data()!, doc.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException('Failed to update invoice: $e',
          code: 'firestore-write-error');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _invoicesCollection.doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete invoice: $e',
          code: 'firestore-write-error');
    }
  }

  @override
  Future<InvoiceDTO> updateStatus(String id, String status,
      {DateTime? paidDate}) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': Timestamp.now(),
      };
      if (paidDate != null) {
        updates['paidDate'] = Timestamp.fromDate(paidDate);
      }

      await _invoicesCollection.doc(id).update(updates);
      final doc = await _invoicesCollection.doc(id).get();
      return InvoiceDTO.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Failed to update invoice status: $e',
          code: 'firestore-write-error');
    }
  }

  @override
  Future<String> getNextInvoiceNumber() async {
    try {
      // Get the highest invoice number - force server read to avoid cache
      final snapshot = await _invoicesCollection
          .orderBy('invoiceNumber', descending: true)
          .limit(1)
          .get(const GetOptions(source: Source.server));

      if (snapshot.docs.isEmpty) {
        return 'INV-0001';
      }

      final lastNumber = snapshot.docs.first.data()['invoiceNumber'] as String?;
      if (lastNumber == null || !lastNumber.startsWith('INV-')) {
        return 'INV-0001';
      }

      final numberPart = lastNumber.substring(4);
      final nextNumber = (int.tryParse(numberPart) ?? 0) + 1;
      return 'INV-${nextNumber.toString().padLeft(4, '0')}';
    } catch (e) {
      throw ServerException('Failed to get next invoice number: $e',
          code: 'firestore-read-error');
    }
  }

  @override
  Future<int> getCount() async {
    try {
      final snapshot = await _invoicesCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw ServerException('Failed to get invoice count: $e',
          code: 'firestore-read-error');
    }
  }

  @override
  Future<int> getMonthlyCount() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final snapshot = await _invoicesCollection
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw ServerException('Failed to get monthly invoice count: $e',
          code: 'firestore-read-error');
    }
  }

  @override
  Future<List<InvoiceDTO>> getOverdue() async {
    try {
      final now = Timestamp.now();
      final snapshot = await _invoicesCollection
          .where('status',
              whereIn: [InvoiceStatus.sent.name, InvoiceStatus.viewed.name])
          .where('dueDate', isLessThan: now)
          .get();
      return snapshot.docs
          .map((doc) => InvoiceDTO.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get overdue invoices: $e',
          code: 'firestore-read-error');
    }
  }
}
