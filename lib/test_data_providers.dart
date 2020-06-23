import 'dart:math';

import 'ld_provider.dart';

class TestLDProvider<T> extends LDProvider<T> {
  static final _rnd = Random();
  List<T> _data = [];
  bool _isLoading = false;
  bool _isEnd = false;

  TestLDProvider({this.gen, this.batchSize = 10, this.length = 100});

  List<T> get data => _data;
  bool get isLoading => _isLoading;
  bool get isEnd => _isEnd;

  final T Function() gen;
  final int length;
  final int batchSize;

  @override
  Future next() {
    if (_isEnd || _isLoading) return null;
    _isLoading = true;
    super.notifyListeners();
    return Future.delayed(Duration(milliseconds: _rnd.nextInt(150) + 75), () {
      if (disposed) return;
      data.addAll(List<T>.filled(batchSize, null).map((_) => gen()));
      _isEnd = data.length > length;
      _isLoading = false;
      super.notifyListeners();
      return;
    });
  }

  void notifyListeners() {
    super.notifyListeners();
  }

  Future refresh() async {
    _data = [];
    _isLoading = false;
    _isEnd = false;
    return next();
  }
}
