import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'ld_provider.dart';

class CrudNetworkProvider<T> extends LDProvider<T> {
  static var baseUrl;
  static var headers = {"Content-Type": "application/json"};
  static Dio get _dio => Dio(BaseOptions(baseUrl: baseUrl, headers: headers))
    ..transformer = FlutterTransformer();

  bool _isLoading = false;
  bool _isEnd = false;
  List<T> _data = [];

  int _offset = 0;
  int _limit = 10;

  final String _path;
  final T Function(Map<String, dynamic> json) fromJson;

  Map<String, String> filter;

  CrudNetworkProvider(this._path,
      {@required this.filter, @required this.fromJson});

  @override
  List<T> get data => _data;

  @override
  bool get isEnd => _isEnd;

  @override
  bool get isLoading => _isLoading;

  String get _filterStr => filter.entries
      .map((it) => "${it.key}=${Uri.encodeComponent(it.value)}")
      .join('&');

  @override
  Future next() async {
    if (_isEnd || _isLoading) return;
    _isLoading = true;
    super.notifyListeners();

    final reqFilter = Map<String, String>.unmodifiable(filter);
    final reqOffset = _offset;
    final reqStr = "$_path?_limit=$_limit&_offset=$_offset&$_filterStr";

    final ans = await _dio.get(reqStr);

    if (ans.statusCode == 200 && ans.data is List) {
      final ls = List<T>.from(ans.data.map((v) => fromJson(v)));
      if (!mapEquals(reqFilter, filter) || reqOffset != _offset) return;

      _isEnd = ls.length < _limit;
      _data.addAll(ls);
      _offset = _offset + _limit;
      return;
    }

    _isLoading = false;
    // FIXME check this work correctly
    if (!disposed) super.notifyListeners();
    return;
  }

  void changeFilter(Map<String, String> newFilter) {
    if (mapEquals(filter, newFilter)) return;

    filter = newFilter;
    _isLoading = false;
    _isEnd = false;
    _data = [];
    _offset = 0;
    super.notifyListeners();
  }

  @override
  Future refresh() {
    _isLoading = false;
    _isEnd = false;
    _data = [];
    _offset = 0;
    super.notifyListeners();
    return next();
  }
}
