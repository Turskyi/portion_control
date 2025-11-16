/// A [UseCase] is a description of the way that an automated system is used.
/// It specifies the [Input] to be provided by the user, the [Output] to be
/// returned to the user. A [UseCase] describes an application-specific business
/// rules.
abstract interface class UseCase<Output, Input> {
  const UseCase();

  Output call([Input input]);
}
