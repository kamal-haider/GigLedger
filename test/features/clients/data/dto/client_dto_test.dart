import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigledger/features/clients/data/dto/client_dto.dart';
import 'package:gigledger/features/clients/domain/models/client.dart';

void main() {
  group('ClientDTO', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final timestamp = Timestamp.fromDate(DateTime(2024, 1, 15));
        final json = {
          'userId': 'user123',
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '+1234567890',
          'address': '123 Main St',
          'notes': 'Important client',
          'totalBilled': 1000.0,
          'totalPaid': 500.0,
          'createdAt': timestamp,
          'updatedAt': timestamp,
        };

        final dto = ClientDTO.fromJson(json, 'doc123');

        expect(dto.id, 'doc123');
        expect(dto.userId, 'user123');
        expect(dto.name, 'John Doe');
        expect(dto.email, 'john@example.com');
        expect(dto.phone, '+1234567890');
        expect(dto.address, '123 Main St');
        expect(dto.notes, 'Important client');
        expect(dto.totalBilled, 1000.0);
        expect(dto.totalPaid, 500.0);
        expect(dto.createdAt, timestamp);
        expect(dto.updatedAt, timestamp);
      });

      test('handles null optional fields', () {
        final json = {
          'userId': 'user123',
          'name': 'John Doe',
        };

        final dto = ClientDTO.fromJson(json, 'doc123');

        expect(dto.id, 'doc123');
        expect(dto.name, 'John Doe');
        expect(dto.email, isNull);
        expect(dto.phone, isNull);
        expect(dto.address, isNull);
        expect(dto.notes, isNull);
        expect(dto.totalBilled, isNull);
        expect(dto.totalPaid, isNull);
      });

      test('handles numeric types for totals', () {
        final json = {
          'name': 'John',
          'totalBilled': 100, // int instead of double
          'totalPaid': 50.5,
        };

        final dto = ClientDTO.fromJson(json, 'doc123');

        expect(dto.totalBilled, 100.0);
        expect(dto.totalPaid, 50.5);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final timestamp = Timestamp.fromDate(DateTime(2024, 1, 15));
        final dto = ClientDTO(
          id: 'doc123',
          userId: 'user123',
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+1234567890',
          address: '123 Main St',
          notes: 'Notes',
          totalBilled: 1000.0,
          totalPaid: 500.0,
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        final json = dto.toJson();

        expect(json['userId'], 'user123');
        expect(json['name'], 'John Doe');
        expect(json['email'], 'john@example.com');
        expect(json['phone'], '+1234567890');
        expect(json['address'], '123 Main St');
        expect(json['notes'], 'Notes');
        expect(json['totalBilled'], 1000.0);
        expect(json['totalPaid'], 500.0);
        // Note: id is not included in toJson as Firestore handles it
        expect(json.containsKey('id'), isFalse);
      });
    });

    group('toDomain', () {
      test('converts to domain model with all fields', () {
        final timestamp = Timestamp.fromDate(DateTime(2024, 1, 15));
        final dto = ClientDTO(
          id: 'doc123',
          userId: 'user123',
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+1234567890',
          address: '123 Main St',
          notes: 'Notes',
          totalBilled: 1000.0,
          totalPaid: 500.0,
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        final client = dto.toDomain();

        expect(client.id, 'doc123');
        expect(client.userId, 'user123');
        expect(client.name, 'John Doe');
        expect(client.email, 'john@example.com');
        expect(client.phone, '+1234567890');
        expect(client.address, '123 Main St');
        expect(client.notes, 'Notes');
        expect(client.totalBilled, 1000.0);
        expect(client.totalPaid, 500.0);
        expect(client.createdAt, DateTime(2024, 1, 15));
      });

      test('throws FormatException when id is null', () {
        final dto = ClientDTO(
          id: null,
          name: 'John Doe',
        );

        expect(
          () => dto.toDomain(),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws FormatException when id is empty', () {
        final dto = ClientDTO(
          id: '',
          name: 'John Doe',
        );

        expect(
          () => dto.toDomain(),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws FormatException when name is null', () {
        final dto = ClientDTO(
          id: 'doc123',
          name: null,
        );

        expect(
          () => dto.toDomain(),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws FormatException when name is empty', () {
        final dto = ClientDTO(
          id: 'doc123',
          name: '',
        );

        expect(
          () => dto.toDomain(),
          throwsA(isA<FormatException>()),
        );
      });

      test('handles null email as empty string', () {
        final dto = ClientDTO(
          id: 'doc123',
          name: 'John Doe',
          email: null,
        );

        final client = dto.toDomain();

        expect(client.email, '');
      });

      test('defaults totals to 0 when null', () {
        final dto = ClientDTO(
          id: 'doc123',
          name: 'John Doe',
          totalBilled: null,
          totalPaid: null,
        );

        final client = dto.toDomain();

        expect(client.totalBilled, 0);
        expect(client.totalPaid, 0);
      });
    });

    group('fromDomain', () {
      test('converts from domain model correctly', () {
        final client = Client(
          id: 'doc123',
          userId: 'user123',
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+1234567890',
          address: '123 Main St',
          notes: 'Notes',
          totalBilled: 1000.0,
          totalPaid: 500.0,
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 20),
        );

        final dto = ClientDTO.fromDomain(client);

        expect(dto.id, 'doc123');
        expect(dto.userId, 'user123');
        expect(dto.name, 'John Doe');
        expect(dto.email, 'john@example.com');
        expect(dto.totalBilled, 1000.0);
        expect(dto.createdAt?.toDate(), DateTime(2024, 1, 15));
      });
    });

    group('round-trip', () {
      test('fromJson -> toDomain -> fromDomain preserves data', () {
        final timestamp = Timestamp.fromDate(DateTime(2024, 1, 15));
        final originalJson = {
          'userId': 'user123',
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '+1234567890',
          'totalBilled': 1000.0,
          'totalPaid': 500.0,
          'createdAt': timestamp,
          'updatedAt': timestamp,
        };

        final dto1 = ClientDTO.fromJson(originalJson, 'doc123');
        final domain = dto1.toDomain();
        final dto2 = ClientDTO.fromDomain(domain);

        expect(dto2.id, dto1.id);
        expect(dto2.userId, dto1.userId);
        expect(dto2.name, dto1.name);
        expect(dto2.email, dto1.email);
        expect(dto2.phone, dto1.phone);
        expect(dto2.totalBilled, dto1.totalBilled);
        expect(dto2.totalPaid, dto1.totalPaid);
      });
    });
  });
}
