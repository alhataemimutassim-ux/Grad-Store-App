import '../entities/slider_image.dart';

abstract class SliderRepository {
  Future<List<SliderImage>> getActiveSliders();
}
