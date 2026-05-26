import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/models/notifikasiModel.dart';

class NotifikasiRepository {
  static final ApiDataSource _api = ApiDataSource();

  Future<List<NotifikasiModel>> getByNik(String nik) =>
      _api.fetchNotifikasiByNik(nik);
}