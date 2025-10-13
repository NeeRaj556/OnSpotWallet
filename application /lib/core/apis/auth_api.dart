import 'package:dio/dio.dart';
import '../../app/utils/logger_utils.dart';
import '../../app/routes/api_routes.dart';
import '../../app/services/service_locator.dart';
import '../../models/user_model.dart';

class AuthApi {
  final _apiClient = ServiceLocator.apiClient;

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(ApiRoutes.login, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data != null) {
        // Save token if provided
        if (response.data['token'] != null) {
          await ServiceLocator.sharedPrefs.setUserToken(response.data['token']);
        }

        // Parse and return user data
        if (response.data['user'] != null) {
          return UserModel.fromJson(response.data['user']);
        }
      }
      return null;
    } on DioException catch (error) {
      logger.e('Login error: $error');
      return null;
    } catch (error) {
      logger.e('Unexpected login error: $error');
      return null;
    }
  }

  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? address,
  }) async {
    try {
      final response = await _apiClient.post(ApiRoutes.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
      });

      if (response.statusCode == 201 && response.data != null) {
        // Save token if provided
        if (response.data['token'] != null) {
          await ServiceLocator.sharedPrefs.setUserToken(response.data['token']);
        }

        // Parse and return user data
        if (response.data['user'] != null) {
          return UserModel.fromJson(response.data['user']);
        }
      }
      return null;
    } on DioException catch (error) {
      logger.e('Register error: $error');
      return null;
    } catch (error) {
      logger.e('Unexpected register error: $error');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      // Clear local token
      await ServiceLocator.sharedPrefs.setUserToken('');
      await ServiceLocator.sharedPrefs.setBool('is_logged_in', false);
    } catch (error) {
      logger.e('Logout error: $error');
    }
  }

  // For development - use mock data
  Future<UserModel> loginMock(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    return UserModel.mockUser;
  }
}
