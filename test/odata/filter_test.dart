import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_services/odata/filter.dart';
import 'package:mobile_services/odata/type.dart';

void main() {
  group('Simple', () {
    test('eq', () {
      final filerBuilder = ODataFilter.builder
          .eq('Simple', EdmType.boolean(true))
          .build
          .toString();
      expect(filerBuilder, 'Simple eq true');
    });

    test('ne', () {
      final filerBuilder = ODataFilter.builder
          .ne('Simple', EdmType.boolean(true))
          .build
          .toString();
      expect(filerBuilder, 'Simple ne true');
    });

    test('le', () {
      final filerBuilder = ODataFilter.builder
          .le('Simple', EdmType.boolean(true))
          .build
          .toString();
      expect(filerBuilder, 'Simple le true');
    });

    test('lt', () {
      final filerBuilder = ODataFilter.builder
          .lt('Simple', EdmType.boolean(true))
          .build
          .toString();
      expect(filerBuilder, 'Simple lt true');
    });

    test('gt', () {
      final filerBuilder = ODataFilter.builder
          .gt('Simple', EdmType.boolean(true))
          .build
          .toString();
      expect(filerBuilder, 'Simple gt true');
    });
    test('ge', () {
      final filerBuilder = ODataFilter.builder
          .ge('Simple', EdmType.boolean(true))
          .build
          .toString();
      expect(filerBuilder, 'Simple ge true');
    });
  });

  group('Logic', (){
    test('and', (){
      final filterOneAnd = ODataFilter.builder
          .ge('One', EdmType.boolean(true))
          .build;
      final filterTwoAnd = ODataFilter.builder
          .ge('Two', EdmType.boolean(true))
          .and
          .gt('Two', EdmType.boolean(true)
          .and(filterOneAnd).build;

      final filterThreeAnd = ODataFilter.builder
          .ge('Three', EdmType.boolean(true))
          .and(filterTwoAnd)
          .build
          .toString();
      print(filterThreeAnd);
    });
  });
}
