sealed class LoadingState<T> {}

class Success<T> extends LoadingState<T> {
  final T response;
  Success(this.response);
}

class Error<T> extends LoadingState<T> {
  final String? message;
  Error([this.message]);
}
