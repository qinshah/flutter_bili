import 'dart:io';

import 'package:flutter_bili/module/login/model/credential_m.dart';
import 'package:flutter_bili/service/auth_s.dart';
import 'package:flutter_bili/service/storage_s.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late AuthS authService;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CredentialsAdapter());
    }
    StorageS.credentialB = await Hive.openBox<CredentialM>(
      'credentials_test',
    );
    StorageS.cacheB = await Hive.openBox<dynamic>('cache_test');
    authService = AuthS.i;
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  group('AuthService credential persistence', () {
    test('saveCredentials then loadFromStorage returns same values', () async {
      await authService.saveCredentials(
        accessKey: 'test_access_key',
        refreshToken: 'test_refresh_token',
        sessdata: 'test_sessdata',
        csrf: 'test_csrf',
      );

      // Create a fresh service instance to simulate app restart
      final freshService = AuthS.i;
      freshService.loadLocalCredential();

      expect(freshService.isLogin, isTrue);
      expect(freshService.accessKey, 'test_access_key');
      expect(freshService.sessdata, 'test_sessdata');
      expect(freshService.csrf, 'test_csrf');
      expect(freshService.credentials?.refreshToken, 'test_refresh_token');
    });

    test(
      'clearCredentials then loadFromStorage returns null credentials',
      () async {
        // First save credentials
        await authService.saveCredentials(
          accessKey: 'test_access_key',
          refreshToken: 'test_refresh_token',
          sessdata: 'test_sessdata',
          csrf: 'test_csrf',
        );
        expect(authService.isLogin, isTrue);

        // Then clear
        await authService.clearCredentials();

        // Fresh service should have no credentials
        final freshService = AuthS.i;
        freshService.loadLocalCredential();

        expect(freshService.isLogin, isFalse);
        expect(freshService.accessKey, isNull);
        expect(freshService.sessdata, isNull);
        expect(freshService.credentials, isNull);
      },
    );

    test('isLogin is false before any credentials are saved', () {
      authService.loadLocalCredential();
      expect(authService.isLogin, isFalse);
    });

    test('isLogin is true after saveCredentials', () async {
      await authService.saveCredentials(
        accessKey: 'key',
        refreshToken: 'refresh',
        sessdata: 'sess',
        csrf: 'csrf',
      );
      expect(authService.isLogin, isTrue);
    });

    test('isLogin is false after clearCredentials', () async {
      await authService.saveCredentials(
        accessKey: 'key',
        refreshToken: 'refresh',
        sessdata: 'sess',
        csrf: 'csrf',
      );
      await authService.clearCredentials();
      expect(authService.isLogin, isFalse);
    });
  });
}
