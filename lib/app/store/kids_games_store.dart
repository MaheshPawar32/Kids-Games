import 'package:velocity_x/velocity_x.dart';

/// Small app-wide store for state that must survive tab widget rebuilds.
///
/// Persistent child/game data belongs in Hive CE repositories, not this UI
/// store. This store holds only transient presentation state.
class KidsGamesStore extends VxStore {
  int selectedTabIndex = 0;
}

/// VxState mutation used by the main navigation bar.
class SelectHomeTab extends VxMutation<KidsGamesStore> {
  SelectHomeTab(this.index);

  final int index;

  @override
  void perform() {
    final currentStore = store;
    if (currentStore != null) {
      currentStore.selectedTabIndex = index;
    }
  }
}
