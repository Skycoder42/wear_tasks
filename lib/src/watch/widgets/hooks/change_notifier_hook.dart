import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HookChangeNotifier extends ChangeNotifier {
  @override
  void notifyListeners() => super.notifyListeners();
}

HookChangeNotifier useChangeNotifier() {
  final notifier = useRef(HookChangeNotifier()).value;
  useEffect(
    () => notifier.dispose,
    [notifier],
  );
  return notifier;
}

void useListenableCallback(Listenable? listenable, VoidCallback callback) {
  useEffect(
    () {
      if (listenable == null) {
        return null;
      }

      listenable.addListener(callback);
      return () => listenable.removeListener(callback);
    },
    [listenable, callback],
  );
}
