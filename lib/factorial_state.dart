/// An abstract implementation of factorial computation state
abstract class FactorialState { 
  const FactorialState({ required this.id });
  final String id;

  @override
  String toString() => '${super.toString()}, ID: $id';

  @override
  bool operator ==(other) => other is FactorialState && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Factorial computation started state
class FactorialStartedState extends FactorialState { 
  const FactorialStartedState({ required super.id }): super();
}

/// Factorial computation progress state
class FactorialProgressState extends FactorialState { 
  const FactorialProgressState({ required super.id, required this.progress }): super();
  final double progress;
  
  @override
  String toString() => '${super.toString()}, Progress: ${(progress * 100).toInt()}%';

  @override
  bool operator ==(other) => other is FactorialProgressState && other.id == id && other.progress == progress;

  @override
  int get hashCode => Object.hash(super.id, progress.hashCode);
}

/// Factorial computation completed state
class FactorialCompletedState extends FactorialState { 
  const FactorialCompletedState({ required super.id, required this.number }): super();
  final BigInt number;

  @override
  String toString() => '${super.toString()}, Value: $number';

  @override
  bool operator ==(other) => other is FactorialCompletedState && other.id == id && other.number == number;
  
  @override
  int get hashCode => Object.hash(super.id, number.hashCode);
}

/// Factorial computation cancelled state
class FactorialCancelledState extends FactorialState { 
  const FactorialCancelledState({ required super.id }): super();
}

/// Factorial computation failed state
class FactorialFailedState extends FactorialState {
  const FactorialFailedState({ required super.id, required this.error }): super();
  final String error;

  @override
  String toString() => '${super.toString()}, Error: $error';

  @override
  bool operator ==(other) => other is FactorialFailedState && other.id == id && other.error == error;
  
  @override
  int get hashCode => Object.hash(super.id, error.hashCode);
}
