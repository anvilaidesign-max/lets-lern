/// Typed failures returned by repositories. Every one carries a message that
/// is safe and friendly to show to the user.
sealed class AppException implements Exception {
  const AppException(this.userMessage, {this.cause});

  final String userMessage;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $userMessage${cause == null ? '' : ' ($cause)'}';
}

class OfflineException extends AppException {
  const OfflineException([super.userMessage = 'You are offline. Connect to the internet and try again.']);
}

class NetworkException extends AppException {
  const NetworkException([super.userMessage = 'We could not reach the server. Please try again.', Object? cause])
      : super(cause: cause);
}

class TimeoutAppException extends AppException {
  const TimeoutAppException([super.userMessage = 'This is taking too long. Please try again.']);
}

class AppAuthException extends AppException {
  const AppAuthException([super.userMessage = 'Please sign in to use this feature.', Object? cause])
      : super(cause: cause);
}

class RateLimitException extends AppException {
  const RateLimitException([super.userMessage = 'You have reached today\'s limit. Try again tomorrow.']);
}

class NotConfiguredException extends AppException {
  const NotConfiguredException([super.userMessage = 'This feature is not set up yet.']);
}

class ValidationException extends AppException {
  const ValidationException(super.userMessage, {super.cause});
}

class NotFoundException extends AppException {
  const NotFoundException([super.userMessage = 'We could not find that.']);
}

class ServerException extends AppException {
  const ServerException([super.userMessage = 'Something went wrong on our side. Please try again later.', Object? cause])
      : super(cause: cause);
}

class CancelledException extends AppException {
  const CancelledException([super.userMessage = 'Cancelled.']);
}

class UnknownException extends AppException {
  const UnknownException([super.userMessage = 'Something went wrong. Please try again.', Object? cause])
      : super(cause: cause);
}
