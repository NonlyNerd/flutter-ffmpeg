import 'dart:async';

class Refreshable {
  void refresh() {}
}

class DialogFactory {
  void dialogShow(String message) {}

  void dialogShowCancellable(String message, Function cancelFunction) {}

  void dialogUpdate(String message) {}

  void dialogHide() {}
}

class Player {
  Future<void> playInVideoTab(String videoPath) async {
    return Future.value();
  }
}

class RefreshablePlayerDialogFactory
    implements Refreshable, Player, DialogFactory {
  @override
  void dialogHide() {}

  @override
  void dialogUpdate(String message) {}

  @override
  void refresh() {}

  @override
  void dialogShow(String message) {}

  @override
  void dialogShowCancellable(String message, Function cancelFunction) {}

  @override
  Future<void> playInVideoTab(String videoPath) async {}
}
