import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter_bili/core/app_storage.dart';
import 'package:flutter_bili/models/auth/credentials.dart';
import 'package:flutter_bili/services/auth_service.dart';

void main() {
  late AuthService authService;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CredentialsAdapter());
    }
    AppStorage.credentials =
        await Hive.openBox<Credentials>('credentials_test');
    AppStorage.cache = await Hive.openBox<dynamic>('cache_test');
    authService = AuthService();
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
      final freshService = AuthService();
      freshService.loadFromStorage();

      expect(freshService.isLogin, isTrue);
      expect(freshService.accessKey, 'test_access_key');
      expect(freshService.sessdata, 'test_sessdata');
      expect(freshService.csrf, 'test_csrf');
      expect(freshService.credentials?.refreshToken, 'test_refresh_token');
    });

    test('clearCredentials then loadFromStorage returns null credentials', () async {
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
      final freshService = AuthService();
      freshService.loadFromStorage();

      expect(freshService.isLogin, isFalse);
      expect(freshService.accessKey, isNull);
      expect(freshService.sessdata, isNull);
      expect(freshService.credentials, isNull);
    });

    test('isLogin is false before any credentials are saved', () {
      authService.loadFromStorage();
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
