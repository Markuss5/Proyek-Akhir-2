import 'package:giliran_ku/core/datasources/apiDataSource.dart';
import 'package:giliran_ku/core/models/ticketModel.dart';

class PharmacyController {
  PharmacyController({QueueApi? api}) : _api = api ?? QueueApi();

  final QueueApi _api;

  Future<Ticket> takeNumber() {
    return _api.getNextPharmacyTicket();
  }
}
