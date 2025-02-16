part of 'yesterday_entries_bloc.dart';

@immutable
sealed class YesterdayEntriesState {
  const YesterdayEntriesState();
}

final class YesterdayEntriesInitial extends YesterdayEntriesState {
  const YesterdayEntriesInitial();
}

class YesterdayEntriesLoading extends YesterdayEntriesState {
  const YesterdayEntriesLoading();
}

class YesterdayEntriesLoaded extends YesterdayEntriesState {
  const YesterdayEntriesLoaded(this.foodEntries);

  final List<FoodWeight> foodEntries;
}

class YesterdayEntriesError extends YesterdayEntriesState {
  const YesterdayEntriesError(this.message);

  final String message;
}
