import 'package:flutter_test/flutter_test.dart';
import 'package:gigledger/features/clients/domain/models/client.dart';

void main() {
  group('Client', () {
    late Client client;

    setUp(() {
      client = Client(
        id: 'client123',
        userId: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        address: '123 Main St',
        notes: 'Important client',
        totalBilled: 1000.0,
        totalPaid: 600.0,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 20),
      );
    });

    group('computed properties', () {
      test('outstandingBalance calculates correctly', () {
        expect(client.outstandingBalance, 400.0);
      });

      test('outstandingBalance is 0 when fully paid', () {
        final paidClient = client.copyWith(totalPaid: 1000.0);
        expect(paidClient.outstandingBalance, 0.0);
      });

      test('outstandingBalance is negative when overpaid', () {
        final overpaidClient = client.copyWith(totalPaid: 1200.0);
        expect(overpaidClient.outstandingBalance, -200.0);
      });

      test('hasOutstandingBalance returns true when balance > 0', () {
        expect(client.hasOutstandingBalance, isTrue);
      });

      test('hasOutstandingBalance returns false when fully paid', () {
        final paidClient = client.copyWith(totalPaid: 1000.0);
        expect(paidClient.hasOutstandingBalance, isFalse);
      });

      test('hasOutstandingBalance returns false when overpaid', () {
        final overpaidClient = client.copyWith(totalPaid: 1200.0);
        expect(overpaidClient.hasOutstandingBalance, isFalse);
      });

      test('isNew returns true when totalBilled is 0', () {
        final newClient = client.copyWith(totalBilled: 0.0);
        expect(newClient.isNew, isTrue);
      });

      test('isNew returns false when client has been billed', () {
        expect(client.isNew, isFalse);
      });
    });

    group('copyWith', () {
      test('creates copy with updated name', () {
        final updated = client.copyWith(name: 'Jane Doe');

        expect(updated.name, 'Jane Doe');
        expect(updated.id, client.id);
        expect(updated.email, client.email);
      });

      test('creates copy with updated totals', () {
        final updated = client.copyWith(
          totalBilled: 2000.0,
          totalPaid: 1500.0,
        );

        expect(updated.totalBilled, 2000.0);
        expect(updated.totalPaid, 1500.0);
        expect(updated.outstandingBalance, 500.0);
      });

      test('preserves all fields when no arguments passed', () {
        final copy = client.copyWith();

        expect(copy.id, client.id);
        expect(copy.userId, client.userId);
        expect(copy.name, client.name);
        expect(copy.email, client.email);
        expect(copy.phone, client.phone);
        expect(copy.address, client.address);
        expect(copy.notes, client.notes);
        expect(copy.totalBilled, client.totalBilled);
        expect(copy.totalPaid, client.totalPaid);
        expect(copy.createdAt, client.createdAt);
        expect(copy.updatedAt, client.updatedAt);
      });
    });

    group('equality', () {
      test('clients with same id, name, email are equal', () {
        final client1 = Client(
          id: 'client123',
          userId: 'user1',
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        final client2 = Client(
          id: 'client123',
          userId: 'user2', // Different userId
          name: 'John Doe',
          email: 'john@example.com',
          totalBilled: 1000.0, // Different totals
          createdAt: DateTime(2024, 2, 1), // Different dates
          updatedAt: DateTime(2024, 2, 1),
        );

        expect(client1, equals(client2));
      });

      test('clients with different id are not equal', () {
        final client1 = Client(
          id: 'client123',
          userId: 'user123',
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        final client2 = Client(
          id: 'client456',
          userId: 'user123',
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        expect(client1, isNot(equals(client2)));
      });

      test('clients with different name are not equal', () {
        final client1 = client;
        final client2 = client.copyWith(name: 'Jane Doe');

        expect(client1, isNot(equals(client2)));
      });

      test('clients with different email are not equal', () {
        final client1 = client;
        final client2 = client.copyWith(email: 'jane@example.com');

        expect(client1, isNot(equals(client2)));
      });
    });

    group('hashCode', () {
      test('equal clients have same hashCode', () {
        final client1 = Client(
          id: 'client123',
          userId: 'user123',
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        final client2 = Client(
          id: 'client123',
          userId: 'user456',
          name: 'John Doe',
          email: 'john@example.com',
          totalBilled: 1000.0,
          createdAt: DateTime(2024, 2, 1),
          updatedAt: DateTime(2024, 2, 1),
        );

        expect(client1.hashCode, equals(client2.hashCode));
      });
    });

    group('default values', () {
      test('totalBilled defaults to 0', () {
        final newClient = Client(
          id: 'client123',
          userId: 'user123',
          name: 'New Client',
          email: 'new@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(newClient.totalBilled, 0.0);
      });

      test('totalPaid defaults to 0', () {
        final newClient = Client(
          id: 'client123',
          userId: 'user123',
          name: 'New Client',
          email: 'new@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(newClient.totalPaid, 0.0);
      });

      test('optional fields can be null', () {
        final minimalClient = Client(
          id: 'client123',
          userId: 'user123',
          name: 'Minimal Client',
          email: 'minimal@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(minimalClient.phone, isNull);
        expect(minimalClient.address, isNull);
        expect(minimalClient.notes, isNull);
      });
    });
  });
}
