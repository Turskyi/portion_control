import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<UpdateBodyWeight>((UpdateBodyWeight event, Emitter<HomeState> emit) {
      emit(BodyWeightUpdatedState(bodyWeight: event.bodyWeight));
    });

    on<SubmitBodyWeight>((SubmitBodyWeight event, Emitter<HomeState> emit) {
      if (state.bodyWeight.isNotEmpty) {
        emit(BodyWeightSubmittedState(bodyWeight: state.bodyWeight));
      }
    });
  }
}
