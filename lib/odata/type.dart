abstract class EdmType {
  EdmType();

  factory EdmType.boolean(bool value) {
    return EdmBoolean(value);
  }

  dynamic get edm;

  String get query;
}

class Null extends EdmType {
  @override
  String? get edm => null;

  @override
  String get query => throw UnimplementedError();

  @override
  String toString() {
    return 'null';
  }
}

class EdmBinary extends Null {
  @override
  // TODO: implement edm
  String get edm => throw UnimplementedError();

  @override
  String toString() {
    return super.toString();
  }
}

class EdmBoolean extends Null {
  final bool value;

  EdmBoolean(this.value);

  @override
  String toString() {
    return value.toString();
  }

  @override
  String get edm => toString();
}

class ODataDateTime extends Null {
  @override
  // TODO: implement edm
  String get edm => throw UnimplementedError();
}
