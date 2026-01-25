import 'package:flutter/foundation.dart';
import 'package:portion_control/domain/services/interactors/save_language_use_case.dart';
import 'package:portion_control/domain/services/interactors/use_case.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';
import 'package:portion_control/router/app_route.dart';

/// Dependencies container.
class Dependencies {
  const Dependencies(this._localDataSource);

  final LocalDataSource _localDataSource;

  UseCase<Future<bool>, String> get saveLanguageUseCase {
    return SaveLanguageUseCase(_localDataSource);
  }

  String get initialRoute {
    if (kIsWeb) {
      return AppRoute.landing.path;
    } else {
      return _localDataSource.isOnboardingCompleted()
          ? AppRoute.home.path
          : AppRoute.onboarding.path;
    }
  }
}
