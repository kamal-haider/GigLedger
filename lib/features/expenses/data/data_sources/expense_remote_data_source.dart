import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/error/exceptions.dart';
import '../dto/expense_dto.dart';

/// Remote data source for expense operations
abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseDTO>> getAll();
  Future<List<ExpenseDTO>> getByDateRange(DateTime start, DateTime end);
  Future<ExpenseDTO?> getById(String id);
  Stream<List<ExpenseDTO>> watchAll();
  Stream<ExpenseDTO?> watch(String id);
  Future<ExpenseDTO> create(ExpenseDTO expense);
  Future<ExpenseDTO> update(ExpenseDTO expense);
  Future<void> delete(String id);
  Future<String> uploadReceipt(String expenseId, String filePath);
  Future<void> deleteReceipt(String receiptUrl);
  Future<int> getCount();
  Future<int> getMonthlyCount();
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ExpenseRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  String get _userId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated', code: 'not-authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _expensesCollection =>
      _firestore.collection('users').doc(_userId).collection('expenses');

  @override
  Future<List<ExpenseDTO>> getAll() async {
    try {
      final snapshot = await _expensesCollection
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ExpenseDTO.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get expenses: $e', code: 'firestore-read-error');
    }
  }

  @override
  Future<List<ExpenseDTO>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _expensesCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ExpenseDTO.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get expenses: $e', code: 'firestore-read-error');
    }
  }

  @override
  Future<ExpenseDTO?> getById(String id) async {
    try {
      final doc = await _expensesCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return ExpenseDTO.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Failed to get expense: $e', code: 'firestore-read-error');
    }
  }

  @override
  Stream<List<ExpenseDTO>> watchAll() {
    return _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseDTO.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<ExpenseDTO?> watch(String id) {
    return _expensesCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return ExpenseDTO.fromJson(doc.data()!, doc.id);
    });
  }

  @override
  Future<ExpenseDTO> create(ExpenseDTO expense) async {
    try {
      final now = Timestamp.now();
      final data = expense.toJson()
        ..['userId'] = _userId
        ..['createdAt'] = now
        ..['updatedAt'] = now;

      final docRef = await _expensesCollection.add(data);
      final doc = await docRef.get();
      return ExpenseDTO.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Failed to create expense: $e', code: 'firestore-write-error');
    }
  }

  @override
  Future<ExpenseDTO> update(ExpenseDTO expense) async {
    try {
      // Defense-in-depth: verify expense belongs to current user
      if (expense.userId != null && expense.userId != _userId) {
        throw const AuthException(
          'Cannot update expense belonging to another user',
          code: 'permission-denied',
        );
      }

      final data = expense.toJson()..['updatedAt'] = Timestamp.now();
      data.remove('createdAt');
      // Ensure userId is set to current user
      data['userId'] = _userId;

      await _expensesCollection.doc(expense.id).update(data);
      final doc = await _expensesCollection.doc(expense.id).get();
      return ExpenseDTO.fromJson(doc.data()!, doc.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException('Failed to update expense: $e', code: 'firestore-write-error');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      // Fetch expense first to check for receipt
      final doc = await _expensesCollection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        final receiptUrl = doc.data()!['receiptUrl'] as String?;
        // Delete receipt from Storage if it exists
        if (receiptUrl != null && receiptUrl.isNotEmpty) {
          try {
            await deleteReceipt(receiptUrl);
          } catch (_) {
            // Log but don't fail deletion if receipt cleanup fails
            // Receipt may have been deleted already or URL may be invalid
          }
        }
      }
      // Delete the expense document
      await _expensesCollection.doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete expense: $e', code: 'firestore-write-error');
    }
  }

  /// Maximum allowed receipt file size (5MB)
  static const int _maxReceiptSizeBytes = 5 * 1024 * 1024;

  /// Allowed receipt file extensions
  static const List<String> _allowedExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.pdf',
  ];

  @override
  Future<String> uploadReceipt(String expenseId, String filePath) async {
    try {
      final file = File(filePath);

      // Validate file exists
      if (!await file.exists()) {
        throw const ServerException(
          'Receipt file does not exist',
          code: 'file-not-found',
        );
      }

      // Validate file size (max 5MB for cost control)
      final fileSize = await file.length();
      if (fileSize > _maxReceiptSizeBytes) {
        throw const ServerException(
          'Receipt file is too large (max 5MB)',
          code: 'file-too-large',
        );
      }

      // Validate file type
      final extension = filePath.toLowerCase().substring(
          filePath.lastIndexOf('.'));
      if (!_allowedExtensions.contains(extension)) {
        throw ServerException(
          'Invalid file type. Allowed: ${_allowedExtensions.join(", ")}',
          code: 'invalid-file-type',
        );
      }

      final ref = _storage.ref().child('users/$_userId/receipts/$expenseId');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to upload receipt: $e', code: 'storage-upload-error');
    }
  }

  @override
  Future<void> deleteReceipt(String receiptUrl) async {
    try {
      final ref = _storage.refFromURL(receiptUrl);
      await ref.delete();
    } catch (e) {
      throw ServerException('Failed to delete receipt: $e', code: 'storage-delete-error');
    }
  }

  @override
  Future<int> getCount() async {
    try {
      final snapshot = await _expensesCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw ServerException('Failed to get expense count: $e', code: 'firestore-read-error');
    }
  }

  @override
  Future<int> getMonthlyCount() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final snapshot = await _expensesCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw ServerException('Failed to get monthly count: $e', code: 'firestore-read-error');
    }
  }
}
