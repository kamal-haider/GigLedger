import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/models/invoice.dart';
import '../../domain/repositories/i_invoice_repository.dart';
import '../data_sources/invoice_remote_data_source.dart';
import '../dto/invoice_dto.dart';

class InvoiceRepositoryImpl implements IInvoiceRepository {
  final InvoiceRemoteDataSource _remoteDataSource;

  InvoiceRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Invoice>> getAll() async {
    try {
      final dtos = await _remoteDataSource.getAll();
      return dtos.map((dto) => dto.toDomain()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<List<Invoice>> getByStatus(InvoiceStatus status) async {
    try {
      final dtos = await _remoteDataSource.getByStatus(status.name);
      return dtos.map((dto) => dto.toDomain()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<List<Invoice>> getByClientId(String clientId) async {
    try {
      final dtos = await _remoteDataSource.getByClientId(clientId);
      return dtos.map((dto) => dto.toDomain()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<Invoice?> getById(String id) async {
    try {
      final dto = await _remoteDataSource.getById(id);
      return dto?.toDomain();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Stream<List<Invoice>> watchAll() {
    return _remoteDataSource.watchAll().map(
          (dtos) => dtos.map((dto) => dto.toDomain()).toList(),
        );
  }

  @override
  Stream<List<Invoice>> watchByStatus(InvoiceStatus status) {
    return _remoteDataSource.watchByStatus(status.name).map(
          (dtos) => dtos.map((dto) => dto.toDomain()).toList(),
        );
  }

  @override
  Stream<Invoice?> watch(String id) {
    return _remoteDataSource.watch(id).map((dto) => dto?.toDomain());
  }

  @override
  Future<Invoice> create(Invoice invoice) async {
    try {
      final dto = InvoiceDTO.fromDomain(invoice);
      final createdDto = await _remoteDataSource.create(dto);
      return createdDto.toDomain();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<Invoice> update(Invoice invoice) async {
    try {
      final dto = InvoiceDTO.fromDomain(invoice);
      final updatedDto = await _remoteDataSource.update(dto);
      return updatedDto.toDomain();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _remoteDataSource.delete(id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<Invoice> markAsSent(String id) async {
    try {
      final dto =
          await _remoteDataSource.updateStatus(id, InvoiceStatus.sent.name);
      return dto.toDomain();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<Invoice> markAsPaid(String id, DateTime paidDate) async {
    try {
      final dto = await _remoteDataSource.updateStatus(
        id,
        InvoiceStatus.paid.name,
        paidDate: paidDate,
      );
      return dto.toDomain();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<String> getNextInvoiceNumber() async {
    try {
      return await _remoteDataSource.getNextInvoiceNumber();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<int> getCount() async {
    try {
      return await _remoteDataSource.getCount();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<int> getMonthlyCount() async {
    try {
      return await _remoteDataSource.getMonthlyCount();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<double> getTotalIncome(DateTime start, DateTime end) async {
    try {
      final dtos = await _remoteDataSource.getAll();
      final invoices = dtos.map((dto) => dto.toDomain()).toList();
      return invoices
          .where((inv) =>
              inv.status == InvoiceStatus.paid &&
              inv.paidDate != null &&
              inv.paidDate!.isAfter(start) &&
              inv.paidDate!.isBefore(end))
          .fold<double>(0.0, (sum, inv) => sum + inv.total);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<List<Invoice>> getOverdue() async {
    try {
      final dtos = await _remoteDataSource.getOverdue();
      return dtos.map((dto) => dto.toDomain()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<Invoice> duplicate(String id) async {
    try {
      final original = await getById(id);
      if (original == null) {
        throw const ServerFailure('Invoice not found', code: 'not-found');
      }

      final nextNumber = await getNextInvoiceNumber();
      final now = DateTime.now();

      final duplicate = Invoice.create(
        id: '',
        userId: original.userId,
        invoiceNumber: nextNumber,
        clientId: original.clientId,
        clientName: original.clientName,
        clientEmail: original.clientEmail,
        lineItems: original.lineItems,
        taxRate: original.taxRate,
        issueDate: now,
        dueDate: now.add(const Duration(days: 30)),
        notes: original.notes,
        terms: original.terms,
        templateId: original.templateId,
      );

      return await create(duplicate);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }
}
