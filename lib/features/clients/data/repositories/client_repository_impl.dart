import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/models/client.dart';
import '../../domain/repositories/i_client_repository.dart';
import '../data_sources/client_remote_data_source.dart';
import '../dto/client_dto.dart';

/// Implementation of IClientRepository using Firestore
class ClientRepositoryImpl implements IClientRepository {
  final ClientRemoteDataSource _dataSource;

  ClientRepositoryImpl(this._dataSource);

  @override
  Future<List<Client>> getAll() async {
    try {
      final dtos = await _dataSource.getAll();
      return dtos.map((dto) => dto.toDomain()).toList();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<Client?> getById(String id) async {
    try {
      final dto = await _dataSource.getById(id);
      return dto?.toDomain();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<List<Client>> search(String query) async {
    try {
      final dtos = await _dataSource.search(query);
      return dtos.map((dto) => dto.toDomain()).toList();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Stream<List<Client>> watchAll() {
    return _dataSource.watchAll().map(
        (dtos) => dtos.map((dto) => dto.toDomain()).toList());
  }

  @override
  Stream<Client?> watch(String id) {
    return _dataSource.watch(id).map((dto) => dto?.toDomain());
  }

  @override
  Future<Client> create(Client client) async {
    try {
      final dto = ClientDTO.fromDomain(client);
      final savedDto = await _dataSource.create(dto);
      return savedDto.toDomain();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<Client> update(Client client) async {
    try {
      final dto = ClientDTO.fromDomain(client);
      final savedDto = await _dataSource.update(dto);
      return savedDto.toDomain();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dataSource.delete(id);
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<int> getCount() async {
    try {
      return await _dataSource.getCount();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<void> updateTotals(String clientId, {double? billed, double? paid}) async {
    try {
      await _dataSource.updateTotals(clientId, billed: billed, paid: paid);
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }
}
