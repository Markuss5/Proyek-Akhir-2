import 'package:giliran_ku/core/datasources/apiDataSource.dart';
import 'package:giliran_ku/core/models/ticketModel.dart';

class BookingController {
  BookingController({QueueApi? api}) : _api = api ?? QueueApi();

  final QueueApi _api;

  Future<Ticket> getTicketByCode(String code) {
    return _api.getTicketByBookingCode(code);
  }
}