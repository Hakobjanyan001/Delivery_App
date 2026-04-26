class ApiConstants {
  // Change this to your production URL when deploying
  static const String baseUrl = 'http://localhost:3000/api';
  // static const String baseUrl = 'https://backend.digicraft.am/api';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String socialLogin = '$baseUrl/auth/social';

  // Banners
  static const String getBanners = '$baseUrl/banner/get-banners';
  static const String getBannerById = '$baseUrl/banner/get-banner-by-id';

  // Restaurants
  static const String getRestaurants = '$baseUrl/restaurant/get-restaurants';
  static const String getRestaurantById = '$baseUrl/restaurant/get-restaurant-by-id';

  // Categories
  static const String getCategories = '$baseUrl/category/get-categories';
  static const String getCategoryById = '$baseUrl/category/get-category-by-id';

  // Products
  static const String getProducts = '$baseUrl/product/get-all';
  static const String getProductById = '$baseUrl/product/get-by-id';

  // User/Client
  static const String confirm18Plus = '$baseUrl/user/confirm-18-plus';
  static const String changeLanguage = '$baseUrl/user/change-language';
  static const String updateProfile = '$baseUrl/user/update-profile';
  static const String getAddresses = '$baseUrl/user/addresses';
  static const String addAddress = '$baseUrl/user/add-address';
  static const String deleteAddress = '$baseUrl/user/delete-address';

  // Orders
  static const String createOrder = '$baseUrl/order/create';
  static const String getMyOrders = '$baseUrl/order/my-orders';
  static const String getOrderById = '$baseUrl/order/get-by-id';

  // Cart
  static const String addToCart = '$baseUrl/cart/add-to-cart';
  static const String deleteFromCart = '$baseUrl/cart/delete-from-cart';
  static const String deleteAllFromCart = '$baseUrl/cart/delete-all-from-cart';
  static const String getCart = '$baseUrl/cart/get-cart';
}
