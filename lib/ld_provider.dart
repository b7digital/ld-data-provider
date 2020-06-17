import 'package:flutter/widgets.dart';

abstract class LDProvider<T> extends ChangeNotifier {
  List<T> get data;
  bool get isLoading;
  bool get isEnd;
  
  bool _disposed = false;

  get disposed => _disposed;

  // Future must be resolved on load end
  Future next();

  void notifyListeners() {
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future refresh() async {}
}
