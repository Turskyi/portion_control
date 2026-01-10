import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:portion_control/domain/enums/language.dart';
import 'package:portion_control/domain/services/interactors/use_case.dart';
import 'package:portion_control/infrastructure/data_sources/local/local_data_source.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._saveLanguageUseCase, LocalDataSource localDataSource)
    : super(OnboardingInitial(localDataSource.getLanguage())) {
    on<ChangeLanguageEvent>(_changeLanguage);
  }

  final UseCase<Future<bool>, String> _saveLanguageUseCase;

  FutureOr<void> _changeLanguage(
    ChangeLanguageEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final Language language = event.language;
    if (language != state.language) {
      final bool isSaved = await _saveLanguageUseCase.call(
        language.isoLanguageCode,
      );
      if (isSaved) {
        emit(OnboardingInitial(language));
      } else {
        emit(OnboardingInitial(state.language));
      }
    }
  }
}
