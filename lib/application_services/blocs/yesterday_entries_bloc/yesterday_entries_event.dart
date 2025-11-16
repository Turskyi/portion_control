part of 'yesterday_entries_bloc.dart';

@immutable
sealed class YesterdayEntriesEvent {
  const YesterdayEntriesEvent();
}

final class LoadYesterdayEntries extends YesterdayEntriesEvent {
  const LoadYesterdayEntries();
}
