import '../../data/api/queue_api.dart';
import '../../data/models/ticket.dart';

class PharmacyController {
  PharmacyController({QueueApi? api}) : _api = api ?? QueueApi();

  final QueueApi _api;

  Future<Ticket> takeNumber() {
    return _api.getNextPharmacyTicket();
  }
}
