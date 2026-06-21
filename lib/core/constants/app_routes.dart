import 'package:flutter/material.dart';

import '../../screens/admin/admin_hub_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/categories/category_detail_screen.dart';
import '../../screens/categories/category_form_screen.dart';
import '../../screens/categories/category_list_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/posts/post_detail_screen.dart';
import '../../screens/posts/post_form_screen.dart';
import '../../screens/posts/post_list_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/store/store_profile_screen.dart';
import '../../screens/stores/store_detail_screen.dart';
import '../../screens/stores/store_form_screen.dart';
import '../../screens/stores/store_list_screen.dart';
import '../../screens/users/user_detail_screen.dart';
import '../../screens/users/user_form_screen.dart';
import '../../screens/users/user_list_screen.dart';
import '../../screens/profile/user_profile_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String notifications = '/notifications';
  static const String home = '/home';
  static const String storeProfile = '/store-profile';
  static const String admin = '/admin';

  static const String userList = '/users';
  static const String userForm = '/users/form';
  static const String userDetail = '/users/detail';
  static const String userProfile = '/user-profile';

  static const String storeList = '/stores';
  static const String storeForm = '/stores/form';
  static const String storeDetail = '/stores/detail';

  static const String categoryList = '/categories';
  static const String categoryForm = '/categories/form';
  static const String categoryDetail = '/categories/detail';

  static const String postList = '/posts';
  static const String postForm = '/posts/form';
  static const String postDetail = '/posts/detail';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    notifications: (context) => const NotificationsScreen(),
    home: (context) => const HomeScreen(),
    storeProfile: (context) => const StoreProfileScreen(),
    admin: (context) => const AdminHubScreen(),
    userList: (context) => const UserListScreen(),
    userForm: (context) => const UserFormScreen(),
    userDetail: (context) => const UserDetailScreen(),
    userProfile: (context) => const UserProfileScreen(),
    storeList: (context) => const StoreListScreen(),
    storeForm: (context) => const StoreFormScreen(),
    storeDetail: (context) => const StoreDetailScreen(),
    categoryList: (context) => const CategoryListScreen(),
    categoryForm: (context) => const CategoryFormScreen(),
    categoryDetail: (context) => const CategoryDetailScreen(),
    postList: (context) => const PostListScreen(),
    postForm: (context) => const PostFormScreen(),
    postDetail: (context) => const PostDetailScreen(),
  };
}
