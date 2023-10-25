import 'dart:io';

import 'package:auth_management/auth_management.dart';
import 'package:data_management/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_strategy/url_strategy.dart';

import '../../index.dart';

/// di reference variable
GetIt locator = GetIt.instance;

/// Root function for di
Future<void> diInit() async {
  /// Base
  await _base();

  await _network();

  await _authorization();

  /// Globalization (ex. https, shared_preferences, etc variables)
  await _globalInit();

  /// Ensure the injections
  await locator.allReady();
}

/// Should be initializing beginning
Future<void> _base() async {
  /// App initialized
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
}

/// Should be initializing ending
Future<void> _globalInit() async {
  HttpOverrides.global = locator<ApplicationHttpOverrides>();
}

/// API or Networks
Future<void> _network() async {
  /// Backup db service
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// ApplicationHttpOverrides
  locator.registerLazySingleton<ApplicationHttpOverrides>(() {
    return ApplicationHttpOverrides();
  });

  /// ApiManager
  locator.registerLazySingleton<ApiManager>(() {
    return ApiManager.getInstance(ApiConstants.baseUrl);
  });

  /// DioManager
  locator.registerLazySingleton<DioManager>(() {
    return DioManager.getInstance(ApiConstants.baseUrl);
  });
}

/// Authorizations
Future<void> _authorization() async {
  /// Auth data source
  locator.registerLazySingleton<AuthDataSource>(() {
    return AuthDataSourceImpl();
  });

  locator.registerLazySingleton<AuthHandler>(() {
    return AuthHandlerImpl(source: locator<AuthDataSource>());
  });

  /// Data management
  /// Remotely
  locator.registerLazySingleton<RemoteDataSource<User>>(() {
    return RemoteUserDataSource();
  });

  locator.registerLazySingleton<RemoteDataRepository<User>>(() {
    return RemoteDataRepositoryImpl(source: locator<RemoteDataSource<User>>());
  });

  locator.registerLazySingleton<RemoteDataHandler<User>>(() {
    return RemoteDataHandlerImpl<User>(
      repository: locator<RemoteDataRepository<User>>(),
    );
  });

  /// Locally
  locator.registerLazySingleton<UserBackupSource>(() {
    return UserBackupSource(locator<RemoteDataHandler<User>>());
  });

  locator.registerLazySingleton<BackupHandler>(() {
    return BackupHandlerImpl(source: locator<UserBackupSource>());
  });

  /// Bloc
  locator.registerFactory<CustomAuthController>(() {
    return CustomAuthController(
      backupHandler: locator<BackupHandler>(),
    );
  });
}
