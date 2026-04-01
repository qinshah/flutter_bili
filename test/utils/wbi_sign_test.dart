import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bili/app/utils/wbi_sign.dart';

void main() {
  // The shuffle table used by WbiSign:
  // [46,47,18,2,53,8,23,32,15,50,10,31,58,3,45,35,
  //  27,43,5,49,33,9,42,19,29,28,14,39,12,38,41,13,
  //  37,48,7,16,24,55,40,61,26,17,0,1,60,51,30,4,
  //  22,25,54,21,56,59,6,63,57,62,11,36,20,34,44,52]

  group('WbiSign.getMixinKey', () {
    // Build a known 64-char input: characters 'a'-'z' repeated + digits
    // We use a predictable string so we can verify the output manually.
    const input =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ab';
    // input[i] for i in 0..63

    test('output is exactly 32 characters', () {
      final result = WbiSign.getMixinKey(input);
      expect(result.length, 32);
    });

    test('output characters come from correct shuffled positions', () {
      const mixinKeyEncTab = <int>[
        46, 47, 18, 2,  53, 8,  23, 32, 15, 50, 10, 31, 58, 3,  45, 35,
        27, 43, 5,  49, 33, 9,  42, 19, 29, 28, 14, 39, 12, 38, 41, 13,
        37, 48, 7,  16, 24, 55, 40, 61, 26, 17, 0,  1,  60, 51, 30, 4,
        22, 25, 54, 21, 56, 59, 6,  63, 57, 62, 11, 36, 20, 34, 44, 52,
      ];

      final result = WbiSign.getMixinKey(input);
      final units = input.codeUnits;

      // Verify first 32 characters match the shuffled positions
      for (var i = 0; i < 32; i++) {
        expect(
          result.codeUnitAt(i),
          units[mixinKeyEncTab[i]],
          reason: 'Position $i should be input[${ mixinKeyEncTab[i]}]',
        );
      }
    });

    test('first character comes from position 46 of input', () {
      final result = WbiSign.getMixinKey(input);
      // mixinKeyEncTab[0] = 46, so result[0] == input[46]
      expect(result[0], input[46]);
    });

    test('second character comes from position 47 of input', () {
      final result = WbiSign.getMixinKey(input);
      // mixinKeyEncTab[1] = 47, so result[1] == input[47]
      expect(result[1], input[47]);
    });

    test('third character comes from position 18 of input', () {
      final result = WbiSign.getMixinKey(input);
      // mixinKeyEncTab[2] = 18, so result[2] == input[18]
      expect(result[2], input[18]);
    });

    test('known input produces expected mixin key', () {
      // Compute expected manually: take input[tab[i]] for i in 0..31
      const mixinKeyEncTab = <int>[
        46, 47, 18, 2,  53, 8,  23, 32, 15, 50, 10, 31, 58, 3,  45, 35,
        27, 43, 5,  49, 33, 9,  42, 19, 29, 28, 14, 39, 12, 38, 41, 13,
      ];
      final expected = String.fromCharCodes(
        mixinKeyEncTab.map((i) => input.codeUnitAt(i)),
      );
      final result = WbiSign.getMixinKey(input);
      expect(result, expected);
    });

    test('longer input still produces 32-char output', () {
      final longInput = 'a' * 128;
      final result = WbiSign.getMixinKey(longInput);
      expect(result.length, 32);
    });
  });
}
