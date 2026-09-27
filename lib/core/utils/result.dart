import '../errors/app_exception.dart';
import 'logger.dart';

/// Success or typed failure. Repositories return this so no exception ever
/// reaches the UI (ARCHITECTURE.md 13.2).
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  AppException? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final error) => error,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(AppException error) failure,
  }) =>
      switch (this) {
        Success<T>(:final value) => success(value),
        Failure<T>(:final error) => failure(error),
      };

  /// Runs [body] and converts any thrown error into a [Failure].
  static Future<Result<T>> guard<T>(Future<T> Function() body, {String? context}) async {
    try {
      return Success(await body());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e, st) {
      AppLogger.error(context ?? 'Result.guard', e, st);
      return Failure(UnknownException('Something went wrong. Please try again.', e));
    }
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppException error;
}
