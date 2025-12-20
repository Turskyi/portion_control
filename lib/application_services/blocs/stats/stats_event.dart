part of 'stats_bloc.dart';

sealed class StatsEvent {
  const StatsEvent();
}

final class LoadStatsEvent extends StatsEvent {
  const LoadStatsEvent();
}
