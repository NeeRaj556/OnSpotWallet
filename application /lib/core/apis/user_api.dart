import 'package:dio/dio.dart';
import '../../app/utils/logger_utils.dart';
import '../../app/routes/api_routes.dart';
import '../../app/services/service_locator.dart';
import '../../models/user_model.dart';

class UserApi {
  final _apiClient = ServiceLocator.apiClient;

  /// Get user profile from API
  Future<UserModel?> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiRoutes.userProfile);

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data['user']);
      }
      return null;
    } on DioException catch (error) {
      logger.e('Get user profile error: $error');
      return null;
    } catch (error) {
      logger.e('Unexpected error getting user profile: $error');
      return null;
    }
  }

  /// Get user balance from API
  Future<double?> getUserBalance() async {
    try {
      final response = await _apiClient.get(ApiRoutes.userBalance);

      if (response.statusCode == 200 && response.data != null) {
        return (response.data['balance'] as num?)?.toDouble();
      }
      return null;
    } on DioException catch (error) {
      logger.e('Get user balance error: $error');
      return null;
    } catch (error) {
      logger.e('Unexpected error getting balance: $error');
      return null;
    }
  }

  /// Update user profile
  Future<UserModel?> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profilePicture,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      if (profilePicture != null) data['profilePicture'] = profilePicture;

      final response = await _apiClient.put(ApiRoutes.userUpdate, data: data);

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data['user']);
      }
      return null;
    } on DioException catch (error) {
      logger.e('Update user profile error: $error');
      return null;
    } catch (error) {
      logger.e('Unexpected error updating profile: $error');
      return null;
    }
  }

  /// Update user location
  Future<bool> updateUserLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.put(ApiRoutes.userUpdate, data: {
        'latitude': latitude,
        'longitude': longitude,
      });

      return response.statusCode == 200;
    } on DioException catch (error) {
      logger.e('Update user location error: $error');
      return false;
    } catch (error) {
      logger.e('Unexpected error updating location: $error');
      return false;
    }
  }

  // For development - use mock data
  Future<UserModel> getUserProfileMock() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return UserModel.mockUser;
  }

  Future<double> getUserBalanceMock() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    return UserModel.mockUser.balance;
  }
}
