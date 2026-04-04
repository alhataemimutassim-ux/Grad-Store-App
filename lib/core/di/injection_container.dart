
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/refresh_token.dart';
import '../../features/auth/domain/usecases/forgot_password.dart';
import '../../features/auth/domain/usecases/reset_password.dart';
import '../../features/auth/presentation/state/auth_provider.dart';

import '../../features/categories/data/datasources/categories_remote_datasource.dart';
import '../../features/categories/data/repositories/categories_repository_impl.dart';
import '../../features/categories/domain/usecases/get_all_categories.dart';
import '../../features/categories/domain/usecases/get_category_by_id.dart';
import '../../features/categories/domain/usecases/create_category.dart';
import '../../features/categories/domain/usecases/update_category.dart';
import '../../features/categories/domain/usecases/delete_category.dart';
import '../../features/categories/presentation/state/categories_provider.dart';

import '../../features/products/data/datasources/products_remote_datasource.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/domain/usecases/get_all_products.dart';
import '../../features/products/domain/usecases/get_product_by_id.dart';
import '../../features/products/domain/usecases/get_admin_products.dart';
import '../../features/products/domain/usecases/create_product.dart';
import '../../features/products/domain/usecases/update_product.dart';
import '../../features/products/domain/usecases/toggle_active_product.dart';
import '../../features/products/domain/usecases/delete_product.dart';
import '../../features/products/presentation/state/products_provider.dart';

import '../../features/productimages/data/datasources/product_images_remote_datasource.dart';
import '../../features/productimages/data/repositories/product_images_repository_impl.dart';
import '../../features/productimages/domain/usecases/get_all_product_images.dart';
import '../../features/productimages/domain/usecases/get_images_by_product_id.dart';
import '../../features/productimages/presentation/state/product_images_provider.dart';

import '../../features/products/data/datasources/reviews_remote_datasource.dart';
import '../../features/products/data/repositories/reviews_repository_impl.dart';
import '../../features/products/domain/usecases/get_reviews_by_product_id.dart';
import '../../features/products/domain/usecases/create_review.dart';
import '../../features/products/presentation/state/reviews_provider.dart';

import '../../features/offers/data/datasources/offers_remote_datasource.dart';
import '../../features/offers/data/repositories/offers_repository_impl.dart';
import '../../features/offers/domain/usecases/get_public_offers.dart';
import '../../features/offers/presentation/state/offers_provider.dart';

import '../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/usecases/get_cart_items.dart';
import '../../features/cart/domain/usecases/add_to_cart.dart';
import '../../features/cart/domain/usecases/update_cart_item.dart';
import '../../features/cart/domain/usecases/delete_cart_item.dart';
import '../../features/cart/domain/usecases/get_cart_item_by_id.dart';
import '../../features/cart/presentation/state/cart_provider.dart';

import '../../features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import '../../features/wishlist/data/repositories/wishlist_repository_impl.dart';
import '../../features/wishlist/domain/usecases/get_my_wishlist.dart';
import '../../features/wishlist/domain/usecases/add_to_wishlist.dart';
import '../../features/wishlist/domain/usecases/remove_from_wishlist.dart';
import '../../features/wishlist/domain/usecases/toggle_wishlist.dart';
import '../../features/wishlist/presentation/state/wishlist_provider.dart';

import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/usecases/get_my_orders.dart';
import '../../features/orders/presentation/state/orders_provider.dart';

import '../../features/studentprofile/data/datasources/student_profile_remote_datasource.dart';
import '../../features/studentprofile/data/repositories/student_profile_repository_impl.dart';
import '../../features/studentprofile/domain/usecases/get_student_profile.dart';
import '../../features/studentprofile/domain/usecases/update_student_profile.dart';
import '../../features/studentprofile/presentation/state/student_profile_provider.dart';

import '../utils/token_manager.dart';
import 'package:provider/single_child_widget.dart';

class InjectionContainer {
  static List<SingleChildWidget> init() {
    final tokenManager = TokenManager();
    final httpClient = http.Client();

    // --- Core ApiClient ---
    // Inject custom ApiClient into datasources when needed.
    // AuthRemoteDataSource needs it because it uses specific helpers.
    final apiClientForAuth = ApiClient(client: httpClient, tokenManager: tokenManager);

    // --- Auth ---
    final authRemote = AuthRemoteDataSourceImpl(apiClientForAuth);
    final authRepo = AuthRepositoryImpl(authRemote);

    // --- Categories ---
    final categoriesRemote = CategoriesRemoteDataSourceImpl(httpClient, tokenManager: tokenManager);
    final categoriesRepo = CategoriesRepositoryImpl(categoriesRemote);

    // --- Products ---
    final productsRemote = ProductsRemoteDataSourceImpl(httpClient, tokenManager: tokenManager);
    final productsRepo = ProductsRepositoryImpl(productsRemote);

    // --- Product Images ---
    final productImagesRemote = ProductImagesRemoteDataSourceImpl(httpClient);
    final productImagesRepo = ProductImagesRepositoryImpl(productImagesRemote);

    // --- Reviews ---
    final reviewsRemote = ReviewsRemoteDataSourceImpl(httpClient, tokenManager: tokenManager);
    final reviewsRepo = ReviewsRepositoryImpl(reviewsRemote);

    // --- Offers ---
    final offersRemote = OffersRemoteDataSourceImpl(httpClient);
    final offersRepo = OffersRepositoryImpl(offersRemote);

    // --- Cart ---
    final cartRemote = CartRemoteDataSourceImpl(httpClient, tokenManager: tokenManager);
    final cartRepo = CartRepositoryImpl(cartRemote);

    // --- Wishlist ---
    final wishlistRemote = WishlistRemoteDataSourceImpl(httpClient, tokenManager: tokenManager);
    final wishlistRepo = WishlistRepositoryImpl(wishlistRemote);

    // --- Orders ---
    final ordersRemote = OrdersRemoteDataSourceImpl(httpClient, tokenManager: tokenManager);
    final ordersRepo = OrdersRepositoryImpl(ordersRemote);

    // --- Student Profile ---
    final studentProfileRemote = StudentProfileRemoteDataSourceImpl(httpClient, tokenManager: tokenManager);
    final studentProfileRepo = StudentProfileRepositoryImpl(studentProfileRemote);

    return [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(
          loginUser: LoginUser(authRepo),
          registerUser: RegisterUser(authRepo),
          logoutUser: LogoutUser(authRepo),
          refreshTokenUseCase: RefreshTokenUseCase(authRepo),
          forgotPasswordUseCase: ForgotPassword(authRepo),
          resetPasswordUseCase: ResetPassword(authRepo),
          tokenManager: tokenManager,
        ),
      ),
      ChangeNotifierProvider<CategoriesProvider>(
        create: (_) => CategoriesProvider(
          getAll: GetAllCategories(categoriesRepo),
          getById: GetCategoryById(categoriesRepo),
          create: CreateCategory(categoriesRepo),
          update: UpdateCategory(categoriesRepo),
          delete: DeleteCategory(categoriesRepo),
        ),
      ),
      ChangeNotifierProvider<ProductsProvider>(
        create: (_) => ProductsProvider(
          getAll: GetAllProducts(productsRepo),
          getById: GetProductById(productsRepo),
          getAdminProducts: GetAdminProducts(productsRepo),
          create: CreateProduct(productsRepo),
          update: UpdateProduct(productsRepo),
          toggleActive: ToggleActiveProduct(productsRepo),
          delete: DeleteProduct(productsRepo),
          tokenManager: tokenManager,
        ),
      ),
      ChangeNotifierProvider<ProductImagesProvider>(
        create: (_) => ProductImagesProvider(
          getAll: GetAllProductImages(productImagesRepo),
          getByProductId: GetImagesByProductId(productImagesRepo),
        ),
      ),
      ChangeNotifierProvider<ReviewsProvider>(
        create: (_) => ReviewsProvider(
          getReviews: GetReviewsByProductId(reviewsRepo),
          createReview: CreateReview(reviewsRepo),
          tokenManager: tokenManager,
        ),
      ),
      ChangeNotifierProvider<OffersProvider>(
        create: (_) => OffersProvider(
          getPublicOffers: GetPublicOffers(offersRepo),
        ),
      ),
      ChangeNotifierProvider<CartProvider>(
        create: (_) => CartProvider(
          getAll: GetCartItems(cartRepo),
          add: AddToCart(cartRepo),
          update: UpdateCartItem(cartRepo),
          delete: DeleteCartItem(cartRepo),
          getById: GetCartItemById(cartRepo),
          client: httpClient,
          tokenManager: tokenManager,
        ),
      ),
      ChangeNotifierProvider<WishlistProvider>(
        create: (_) => WishlistProvider(
          getMyWishlist: GetMyWishlist(wishlistRepo),
          addToWishlist: AddToWishlist(wishlistRepo),
          removeFromWishlist: RemoveFromWishlist(wishlistRepo),
          toggleWishlist: ToggleWishlist(wishlistRepo),
        ),
      ),
      ChangeNotifierProvider<OrdersProvider>(
        create: (_) => OrdersProvider(
          getMyOrders: GetMyOrders(ordersRepo),
          tokenManager: tokenManager,
        ),
      ),
      ChangeNotifierProvider<StudentProfileProvider>(
        create: (_) => StudentProfileProvider(
          getProfile: GetStudentProfile(studentProfileRepo),
          updateProfile: UpdateStudentProfile(studentProfileRepo),
          tokenManager: tokenManager,
        ),
      ),
    ];
  }
}
