import '../entities/slider_image.dart';
import '../repositories/slider_repository.dart';

class GetActiveSliders {
  final SliderRepository repository;

  GetActiveSliders(this.repository);

  Future<List<SliderImage>> execute() async {
    return await repository.getActiveSliders();
  }
}
