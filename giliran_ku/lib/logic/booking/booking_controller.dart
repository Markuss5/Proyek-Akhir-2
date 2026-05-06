import '../../data/api/queue_api.dart';
import '../../data/models/ticket.dart';

class BookingController {
  BookingController({QueueApi? api}) : _api = api ?? QueueApi();

  final QueueApi _api;

  Future<Ticket> getTicketByCode(String code) {
    return _api.getTicketByBookingCode(code);
  }
}
