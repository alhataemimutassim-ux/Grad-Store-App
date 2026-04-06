import '../../domain/entities/slider_image.dart';
import '../../domain/repositories/slider_repository.dart';
import '../datasources/slider_remote_datasource.dart';

class SliderRepositoryImpl implements SliderRepository {
  final SliderRemoteDataSource remoteDataSource;

  SliderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SliderImage>> getActiveSliders() async {
    final sliders = await remoteDataSource.getSliders();
    // ترتيب وتصفية السلايدرات (يمكن عملها هنا أو في الـ Provider والأفضل هنا كونه Business Rule بسيط)
    final activeSliders = sliders.where((s) => s.isActive).toList();
    activeSliders.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return activeSliders;
  }
}
