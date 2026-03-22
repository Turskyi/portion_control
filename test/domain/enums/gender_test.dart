import 'package:flutter_test/flutter_test.dart';
import 'package:portion_control/domain/enums/gender.dart';
import 'package:portion_control/domain/models/user_details.dart';

void main() {
  group('Gender.fromString', () {
    test('parses stable persisted identifiers', () {
      expect(Gender.fromString('male'), Gender.male);
      expect(Gender.fromString('female'), Gender.female);
      expect(Gender.fromString('other'), Gender.other);
      expect(
        Gender.fromString('prefer_not_to_say'),
        Gender.preferNotToSay,
      );
    });

    test('parses enum names and legacy English labels', () {
      expect(Gender.fromString('preferNotToSay'), Gender.preferNotToSay);
      expect(Gender.fromString('Prefer not to say'), Gender.preferNotToSay);
    });

    test('falls back to preferNotToSay for unknown values', () {
      expect(Gender.fromString(''), Gender.preferNotToSay);
      expect(Gender.fromString('unknown'), Gender.preferNotToSay);
    });
  });

  group('UserDetails gender serialization', () {
    test('stores a stable gender key that round-trips through fromMap', () {
      const UserDetails userDetails = UserDetails(
        heightInCm: 180,
        gender: Gender.preferNotToSay,
        dateOfBirth: null,
      );

      final Map<String, dynamic> map = userDetails.toMap();
      final UserDetails restored = UserDetails.fromMap(map);

      expect(map['gender'], 'prefer_not_to_say');
      expect(restored.gender, Gender.preferNotToSay);
    });
  });
}
