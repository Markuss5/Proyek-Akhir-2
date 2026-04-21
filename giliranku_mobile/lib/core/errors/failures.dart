/// Base failure class — all domain-level errors extend this.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// The device could not reach the server (no internet / wrong IP).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak dapat terhubung ke server.']);
}

/// The server returned a non-success HTTP status code.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Terjadi kesalahan pada server.']);
}

/// A requested resource was not found (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Data tidak ditemukan.']);
}

/// Validation failed before even hitting the network.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
