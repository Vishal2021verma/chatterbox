import 'package:flutter/foundation.dart';

class LoadingProvider extends ChangeNotifier {
  LoadingProvider();
  bool _isloading = false;
  bool get isLoading => _isloading;
  set isLoading(bool loadingState) {
    _isloading = loadingState;
    notifyListeners();
  }
}
