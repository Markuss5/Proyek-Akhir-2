import 'package:giliran_ku/core/datasources/apiDataSource.dart';
import 'package:giliran_ku/core/models/doctorModel.dart';
import 'package:giliran_ku/core/models/patientModel.dart';
import 'package:giliran_ku/core/models/poliModel.dart';
import 'package:giliran_ku/core/models/ticketModel.dart';

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
