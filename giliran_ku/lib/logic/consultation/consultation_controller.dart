import '../../data/api/queue_api.dart';
import '../../data/models/doctor.dart';
import '../../data/models/patient.dart';
import '../../data/models/poli.dart';
import '../../data/models/ticket.dart';

class ConsultationController {
  ConsultationController({QueueApi? api}) : _api = api ?? QueueApi();

  final QueueApi _api;

  Future<Ticket> createTicketForBpjs(String nikOrBpjs) {
    return _api.createBpjsTicket(nikOrBpjs);
  }

  Future<Patient> validateNik(String nik) {
    return _api.validateNik(nik);
  }

  Future<List<Poli>> fetchPoliList() {
    return _api.getPoliList();
  }

  Future<List<Doctor>> fetchDoctors(String poliId) {
    return _api.getDoctors(poliId);
  }

  Future<Ticket> createTicketForGeneral({
    required String nik,
    required Poli poli,
    required Doctor doctor,
  }) {
    return _api.createGeneralTicket(
      nik: nik,
      poli: poli,
      doctor: doctor,
    );
  }
}
