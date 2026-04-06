import 'package:flutter/material.dart';
import '../../domain/entities/slider_image.dart';
import '../../domain/usecases/get_active_sliders.dart';

enum SliderStatus { initial, loading, loaded, error }

class SliderProvider with ChangeNotifier {
  final GetActiveSliders getActiveSliders;

  SliderProvider({required this.getActiveSliders});

  SliderStatus _status = SliderStatus.initial;
  SliderStatus get status => _status;

  List<SliderImage> _sliders = [];
  List<SliderImage> get sliders => _sliders;

  String _error = '';
  String get error => _error;

  Future<void> fetchSliders() async {
    _status = SliderStatus.loading;
    notifyListeners();
    try {
      final data = await getActiveSliders.execute();
      _sliders = data;
      _status = SliderStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = SliderStatus.error;
    }
    notifyListeners();
  }
}
