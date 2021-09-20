import 'package:mobile_services/odata/type.dart';

class ODataFilter {
  final String _filter;

  static ODataFilterBuilder get builder {
    return ODataFilterBuilder();
  }

  ODataFilter(this._filter);

  @override
  String toString() {
    return this._filter;
  }
}

abstract class _ODataFilterPart {
  _ODataFilterPart();
}

class _ODataFilterPartBinary extends _ODataFilterPart {
  final String _part;

  _ODataFilterPartBinary(String property, String operation, String value)
      : this._part = '$property $operation $value';

  @override
  String toString() {
    return _part;
  }
}

class _ODataFilterPartLogic extends _ODataFilterPart {
  final String _part;
  final ODataFilter _filter;

  _ODataFilterPartLogic(String logic, ODataFilter filter)
      : this._part = '$logic',
        this._filter = filter;

  @override
  String toString() {
    return '$_part ($_filter)';
  }
}

class ODataFilterBuilder {
  List<_ODataFilterPart> _filter = [];

  ODataFilterBuilder eq(String name, EdmType value) {
    _filter.add(_ODataFilterPartBinary(name, 'eq', value.toString()));
    return this;
  }

  ODataFilterBuilder ne(String name, EdmType value) {
    _filter.add(_ODataFilterPartBinary(name, 'ne', value.toString()));
    return this;
  }

  ODataFilterBuilder le(String name, EdmType value) {
    _filter.add(_ODataFilterPartBinary(name, 'le', value.toString()));
    return this;
  }

  ODataFilterBuilder lt(String name, EdmType value) {
    _filter.add(_ODataFilterPartBinary(name, 'lt', value.toString()));
    return this;
  }

  ODataFilterBuilder ge(String name, EdmType value) {
    _filter.add(_ODataFilterPartBinary(name, 'ge', value.toString()));
    return this;
  }

  ODataFilterBuilder gt(String name, EdmType value) {
    _filter.add(_ODataFilterPartBinary(name, 'gt', value.toString()));
    return this;
  }
  ODataFilterBuilder get and {
    return this;
  }

  ODataFilterBuilder get or {
    return this;
  }

  ODataFilterBuilder andGroup(ODataFilter filter) {
    _filter.add(_ODataFilterPartLogic('and', filter));
    return this;
  }

  ODataFilterBuilder orGroup(ODataFilter filter) {
    _filter.add(_ODataFilterPartLogic('or', filter));
    return this;
  }

  ODataFilter get build {
    String filter = _filter.fold('', (previousValue, element) {
      if (element is _ODataFilterPartBinary) {
        previousValue = '$element $previousValue'.trim();
      } else if (element is _ODataFilterPartLogic) {
        previousValue = '($previousValue) $element'.trim();
      }
      return previousValue;
    });
    return ODataFilter(filter);
  }
}
