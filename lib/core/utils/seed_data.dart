import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Seeds test data for development and testing purposes
class SeedData {
  static final _firestore = FirebaseFirestore.instance;

  /// Seeds sample invoices, expenses, and clients for the current user
  static Future<void> seedTestData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    final uid = user.uid;
    final now = DateTime.now();
    final batch = _firestore.batch();

    // Add sample clients
    final clientsRef = _firestore.collection('users/$uid/clients');
    final client1Id = clientsRef.doc().id;
    final client2Id = clientsRef.doc().id;
    final client3Id = clientsRef.doc().id;

    batch.set(clientsRef.doc(client1Id), {
      'name': 'Acme Corporation',
      'email': 'billing@acme.com',
      'phone': '+1 555-0100',
      'address': '123 Business Ave, New York, NY 10001',
      'notes': 'Enterprise client - net 30 terms',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 60))),
      'updatedAt': Timestamp.fromDate(now),
    });

    batch.set(clientsRef.doc(client2Id), {
      'name': 'TechStart Inc',
      'email': 'accounts@techstart.io',
      'phone': '+1 555-0200',
      'address': '456 Startup Blvd, San Francisco, CA 94105',
      'notes': 'Monthly retainer client',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 45))),
      'updatedAt': Timestamp.fromDate(now),
    });

    batch.set(clientsRef.doc(client3Id), {
      'name': 'Creative Agency LLC',
      'email': 'hello@creativeagency.co',
      'phone': '+1 555-0300',
      'address': '789 Design St, Austin, TX 78701',
      'notes': 'Project-based work',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
      'updatedAt': Timestamp.fromDate(now),
    });

    // Add sample invoices
    final invoicesRef = _firestore.collection('users/$uid/invoices');

    // Paid invoice (last month)
    batch.set(invoicesRef.doc(), {
      'invoiceNumber': 'INV-001',
      'clientId': client1Id,
      'clientName': 'Acme Corporation',
      'clientEmail': 'billing@acme.com',
      'lineItems': [
        {
          'description': 'Web Development',
          'quantity': 40,
          'rate': 150.0,
          'amount': 6000.0
        },
        {
          'description': 'UI/UX Design',
          'quantity': 20,
          'rate': 125.0,
          'amount': 2500.0
        },
      ],
      'subtotal': 8500.0,
      'taxRate': 0.0,
      'taxAmount': 0.0,
      'total': 8500.0,
      'status': 'paid',
      'issueDate': Timestamp.fromDate(now.subtract(const Duration(days: 45))),
      'dueDate': Timestamp.fromDate(now.subtract(const Duration(days: 15))),
      'paidDate': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
      'notes': 'Thank you for your business!',
      'templateId': 'default',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 45))),
      'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
    });

    // Paid invoice (this month)
    batch.set(invoicesRef.doc(), {
      'invoiceNumber': 'INV-002',
      'clientId': client2Id,
      'clientName': 'TechStart Inc',
      'clientEmail': 'accounts@techstart.io',
      'lineItems': [
        {
          'description': 'Monthly Retainer - January',
          'quantity': 1,
          'rate': 5000.0,
          'amount': 5000.0
        },
      ],
      'subtotal': 5000.0,
      'taxRate': 0.0,
      'taxAmount': 0.0,
      'total': 5000.0,
      'status': 'paid',
      'issueDate': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
      'dueDate': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
      'paidDate': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
      'notes': 'Monthly retainer payment',
      'templateId': 'default',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
      'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
    });

    // Sent invoice (pending)
    batch.set(invoicesRef.doc(), {
      'invoiceNumber': 'INV-003',
      'clientId': client3Id,
      'clientName': 'Creative Agency LLC',
      'clientEmail': 'hello@creativeagency.co',
      'lineItems': [
        {
          'description': 'Brand Identity Design',
          'quantity': 1,
          'rate': 3500.0,
          'amount': 3500.0
        },
        {
          'description': 'Logo Variations',
          'quantity': 5,
          'rate': 200.0,
          'amount': 1000.0
        },
      ],
      'subtotal': 4500.0,
      'taxRate': 8.25,
      'taxAmount': 371.25,
      'total': 4871.25,
      'status': 'sent',
      'issueDate': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
      'dueDate': Timestamp.fromDate(now.add(const Duration(days: 25))),
      'paidDate': null,
      'notes': 'Payment due within 30 days',
      'templateId': 'default',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
      'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
    });

    // Overdue invoice
    batch.set(invoicesRef.doc(), {
      'invoiceNumber': 'INV-004',
      'clientId': client1Id,
      'clientName': 'Acme Corporation',
      'clientEmail': 'billing@acme.com',
      'lineItems': [
        {
          'description': 'API Integration',
          'quantity': 15,
          'rate': 175.0,
          'amount': 2625.0
        },
      ],
      'subtotal': 2625.0,
      'taxRate': 0.0,
      'taxAmount': 0.0,
      'total': 2625.0,
      'status': 'overdue',
      'issueDate': Timestamp.fromDate(now.subtract(const Duration(days: 40))),
      'dueDate': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
      'paidDate': null,
      'notes': 'OVERDUE - Please remit payment',
      'templateId': 'default',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 40))),
      'updatedAt': Timestamp.fromDate(now),
    });

    // Add sample expenses
    final expensesRef = _firestore.collection('users/$uid/expenses');

    batch.set(expensesRef.doc(), {
      'userId': uid,
      'amount': 149.99,
      'category': 'software',
      'description': 'Adobe Creative Cloud - Monthly',
      'vendor': 'Adobe',
      'receiptUrl': null,
      'date': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
      'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
    });

    batch.set(expensesRef.doc(), {
      'userId': uid,
      'amount': 89.00,
      'category': 'software',
      'description': 'Figma Professional',
      'vendor': 'Figma',
      'receiptUrl': null,
      'date': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
      'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
    });

    batch.set(expensesRef.doc(), {
      'userId': uid,
      'amount': 45.50,
      'category': 'office',
      'description': 'Office supplies from Staples',
      'vendor': 'Staples',
      'receiptUrl': null,
      'date': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
      'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
    });

    batch.set(expensesRef.doc(), {
      'userId': uid,
      'amount': 125.00,
      'category': 'travel',
      'description': 'Client meeting - Uber rides',
      'vendor': 'Uber',
      'receiptUrl': null,
      'date': Timestamp.fromDate(now.subtract(const Duration(days: 12))),
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 12))),
      'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 12))),
    });

    batch.set(expensesRef.doc(), {
      'userId': uid,
      'amount': 350.00,
      'category': 'equipment',
      'description': 'External monitor stand',
      'vendor': 'Amazon',
      'receiptUrl': null,
      'date': Timestamp.fromDate(now.subtract(const Duration(days: 20))),
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 20))),
      'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 20))),
    });

    // Commit all changes
    await batch.commit();
  }

  /// Clears all test data for the current user
  static Future<void> clearTestData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    final uid = user.uid;

    // Delete all invoices
    final invoices = await _firestore.collection('users/$uid/invoices').get();
    for (final doc in invoices.docs) {
      await doc.reference.delete();
    }

    // Delete all expenses
    final expenses = await _firestore.collection('users/$uid/expenses').get();
    for (final doc in expenses.docs) {
      await doc.reference.delete();
    }

    // Delete all clients
    final clients = await _firestore.collection('users/$uid/clients').get();
    for (final doc in clients.docs) {
      await doc.reference.delete();
    }
  }
}
