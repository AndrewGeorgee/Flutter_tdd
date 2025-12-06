import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd/models/priority.dart';

void main() {
  group('Priority', () {
    test('should have correct values', () {
      expect(Priority.low.value, 1);
      expect(Priority.medium.value, 2);
      expect(Priority.high.value, 3);
      expect(Priority.urgent.value, 4);
    });

    test('should create priority from value', () {
      expect(Priority.fromValue(1), Priority.low);
      expect(Priority.fromValue(2), Priority.medium);
      expect(Priority.fromValue(3), Priority.high);
      expect(Priority.fromValue(4), Priority.urgent);
      expect(Priority.fromValue(99), Priority.medium); // default
    });
  });
}

