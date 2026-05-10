class Mission {
  final String title;
  final String reward;
  final int target;
  final String unitSuffix;
  final int current;
  final bool isDone;

  const Mission({
    required this.title,
    required this.reward,
    required this.target,
    required this.unitSuffix,
    required this.current,
    required this.isDone,
  });

  String get progressLabel => '$current$unitSuffix / $target$unitSuffix';
}

class MissionLevel {
  final String title;
  final String reward;
  final int target;

  const MissionLevel({
    required this.title,
    required this.reward,
    required this.target,
  });
}

class MissionFactory {
  static Mission fromValue({
    required int value,
    required List<MissionLevel> levels,
    required String unitSuffix,
    required int endlessStep,
    required String Function(int target) endlessTitleBuilder,
    required String Function(int target) endlessRewardBuilder,
  }) {
    for (final level in levels) {
      if (value < level.target) {
        return Mission(
          title: level.title,
          reward: level.reward,
          target: level.target,
          unitSuffix: unitSuffix,
          current: value.clamp(0, level.target),
          isDone: false,
        );
      }
    }
    final finalLevel = levels.last;
    final overflow = (value - finalLevel.target).clamp(0, 1000000);
    final endlessTarget =
        finalLevel.target + (((overflow ~/ endlessStep) + 1) * endlessStep);
    return Mission(
      title: endlessTitleBuilder(endlessTarget),
      reward: endlessRewardBuilder(endlessTarget),
      target: endlessTarget,
      unitSuffix: unitSuffix,
      current: value.clamp(0, endlessTarget),
      isDone: false,
    );
  }
}
