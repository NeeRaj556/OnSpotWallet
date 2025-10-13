import 'package:dio/dio.dart';
import '../../app/utils/logger_utils.dart';
import '../../app/routes/api_routes.dart';
import '../../app/services/service_locator.dart';
import '../../models/transaction_model.dart';

class TransactionApi {
  final _apiClient = ServiceLocator.apiClient;

  /// Get all transactions for current user
  Future<List<TransactionModel>?> getTransactions({
    TransactionMode? mode,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (mode != null) {
        queryParams['mode'] =
            mode == TransactionMode.online ? 'online' : 'offline';
      }
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.get(
        ApiRoutes.transactions,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> transactionsList =
            response.data['transactions'] ?? [];
        return transactionsList
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      }
      return null;
    } on DioException catch (error) {
      logger.e('Get transactions error: $error');
      return null;
    } catch (error) {
      logger.e('Unexpected error getting transactions: $error');
      return null;
    }
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final route = ApiRoutes.transactionById.replaceAll(':id', id);
      final response = await _apiClient.get(route);

      if (response.statusCode == 200 && response.data != null) {
        return TransactionModel.fromJson(response.data['transaction']);
      }
      return null;
    } on DioException catch (error) {
      logger.e('Get transaction by ID error: $error');
      return null;
    } catch (error) {
      logger.e('Unexpected error getting transaction: $error');
      return null;
    }
  }

  /// Send transaction to another user
  Future<TransactionModel?> sendTransaction({
    required String receiverId,
    required double amount,
    required TransactionMode mode,
    double? latitude,
    double? longitude,
    String? purpose,
  }) async {
    try {
      final response = await _apiClient.post(ApiRoutes.sendTransaction, data: {
        'receiverId': receiverId,
        'amount': amount,
        'mode': mode == TransactionMode.online ? 'online' : 'offline',
        'latitude': latitude,
        'longitude': longitude,
        'purpose': purpose,
      });

      if (response.statusCode == 201 && response.data != null) {
        return TransactionModel.fromJson(response.data['transaction']);
      }
      return null;
    } on DioException catch (error) {
      logger.e('Send transaction error: $error');
      return null;
    } catch (error) {
      logger.e('Unexpected error sending transaction: $error');
      return null;
    }
  }

  /// Get transaction history with filters
  Future<List<TransactionModel>?> getTransactionHistory({
    DateTime? startDate,
    DateTime? endDate,
    TransactionMode? mode,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (mode != null) {
        queryParams['mode'] =
            mode == TransactionMode.online ? 'online' : 'offline';
      }

      final response = await _apiClient.get(
        ApiRoutes.transactionHistory,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> transactionsList =
            response.data['transactions'] ?? [];
        return transactionsList
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      }
      return null;
    } on DioException catch (error) {
      logger.e('Get transaction history error: $error');
      return null;
    } catch (error) {
      logger.e('Unexpected error getting transaction history: $error');
      return null;
    }
  }

  /// Get monthly statistics
  Future<Map<String, dynamic>?> getMonthlyStats({int? month, int? year}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _apiClient.get(
        ApiRoutes.monthlyStats,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['stats'];
      }
      return null;
    } on DioException catch (error) {
      logger.e('Get monthly stats error: $error');
      return null;
    } catch (error) {
      logger.e('Unexpected error getting monthly stats: $error');
      return null;
    }
  }

  // For development - use mock data
  Future<List<TransactionModel>> getTransactionsMock({
    TransactionMode? mode,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (mode != null) {
      return TransactionModel.mockTransactions
          .where((tx) => tx.mode == mode)
          .toList();
    }
    return TransactionModel.mockTransactions;
  }

  Future<Map<String, dynamic>> getMonthlyStatsMock() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      'totalSent': 1450.0,
      'totalReceived': 500.0,
      'transactionCount': 3,
      'onlineCount': 2,
      'offlineCount': 1,
    };
  }
}
