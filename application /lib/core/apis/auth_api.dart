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
        final data =
            response.data['data']; // API wraps response in "data" field

        // Save token from response
        if (data['token'] != null) {
          await ServiceLocator.sharedPrefs.setUserToken(data['token']);
        }

        // Get user data from nested "user" object
        final userData = data['user'];

        if (userData != null) {
          // Save all user data to SharedPreferences
          await ServiceLocator.sharedPrefs
              .setString('user_id', userData['id'] ?? '');
          await ServiceLocator.sharedPrefs
              .setString('user_name', userData['name'] ?? 'User');
          await ServiceLocator.sharedPrefs
              .setString('user_email', userData['email'] ?? email);
          await ServiceLocator.sharedPrefs
              .setString('user_role', userData['role'] ?? 'user');
          await ServiceLocator.sharedPrefs
              .setString('user_phone', userData['phone'] ?? '');
          await ServiceLocator.sharedPrefs
              .setString('user_address', userData['address'] ?? '');
          await ServiceLocator.sharedPrefs
              .setString('user_currency', userData['currency'] ?? '\$');

          // Save balance as double
          if (userData['balance'] != null) {
            await ServiceLocator.sharedPrefs.setDouble(
                'user_balance', (userData['balance'] as num).toDouble());
          }

          // Save online and offline balances
          if (userData['onlineBalance'] != null) {
            await ServiceLocator.sharedPrefs.setDouble('user_online_balance',
                (userData['onlineBalance'] as num).toDouble());
          }
          if (userData['offlineBalance'] != null) {
            await ServiceLocator.sharedPrefs.setDouble('user_offline_balance',
                (userData['offlineBalance'] as num).toDouble());
          }

          // Save limits
          if (userData['onlineLimit'] != null) {
            await ServiceLocator.sharedPrefs.setDouble('user_online_limit',
                (userData['onlineLimit'] as num).toDouble());
          }
          if (userData['offlineLimit'] != null) {
            await ServiceLocator.sharedPrefs.setDouble('user_offline_limit',
                (userData['offlineLimit'] as num).toDouble());
          }

          // Save profile picture if exists
          if (userData['profilePicture'] != null) {
            await ServiceLocator.sharedPrefs
                .setString('user_profile_picture', userData['profilePicture']);
          }

          await ServiceLocator.sharedPrefs.setBool('is_logged_in', true);

          logger.i('Login successful for: ${userData['name']}');

          // Return UserModel
          return UserModel.fromJson(userData);
        }
      }
      return null;
    } on DioException catch (error) {
      logger.e('Login error: ${error.message}');
      rethrow;
    } catch (error) {
      logger.e('Unexpected login error: $error');
      rethrow;
    }
  }

  // Fetch current user data (for refresh/app restart)
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiRoutes.userMe);

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data'];

        if (userData != null) {
          // Update SharedPreferences with latest data
          await ServiceLocator.sharedPrefs
              .setString('user_id', userData['id'] ?? '');
          await ServiceLocator.sharedPrefs
              .setString('user_name', userData['name'] ?? 'User');
          await ServiceLocator.sharedPrefs
              .setString('user_email', userData['email'] ?? '');
          await ServiceLocator.sharedPrefs
              .setString('user_role', userData['role'] ?? 'user');
          await ServiceLocator.sharedPrefs
              .setString('user_phone', userData['phone'] ?? '');
          await ServiceLocator.sharedPrefs
              .setString('user_address', userData['address'] ?? '');
          await ServiceLocator.sharedPrefs
              .setString('user_currency', userData['currency'] ?? '\$');

          if (userData['balance'] != null) {
            await ServiceLocator.sharedPrefs.setDouble(
                'user_balance', (userData['balance'] as num).toDouble());
          }

          // Save online and offline balances
          if (userData['onlineBalance'] != null) {
            await ServiceLocator.sharedPrefs.setDouble('user_online_balance',
                (userData['onlineBalance'] as num).toDouble());
          }
          if (userData['offlineBalance'] != null) {
            await ServiceLocator.sharedPrefs.setDouble('user_offline_balance',
                (userData['offlineBalance'] as num).toDouble());
          }

          // Save limits
          if (userData['onlineLimit'] != null) {
            await ServiceLocator.sharedPrefs.setDouble('user_online_limit',
                (userData['onlineLimit'] as num).toDouble());
          }
          if (userData['offlineLimit'] != null) {
            await ServiceLocator.sharedPrefs.setDouble('user_offline_limit',
                (userData['offlineLimit'] as num).toDouble());
          }

          if (userData['profilePicture'] != null) {
            await ServiceLocator.sharedPrefs
                .setString('user_profile_picture', userData['profilePicture']);
          }

          logger.i('User data refreshed for: ${userData['name']}');

          return UserModel.fromJson(userData);
        }
      }
      return null;
    } on DioException catch (error) {
      logger.e('Get current user error: ${error.message}');
      return null;
    } catch (error) {
      logger.e('Unexpected get user error: $error');
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
