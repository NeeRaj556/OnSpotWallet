import 'package:dio/dio.dart';
import '../../models/user_model.dart';
import '../../models/transaction_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  bool _isInitialized = false;

  // Base URL - Replace with your actual API URL
  static const String baseUrl = 'https://your-api-url.com/api';

  // Use mock data for now
  static const bool useMockData = true;

  void initialize({String? customBaseUrl}) {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: customBaseUrl ?? baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and auth
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          final token = _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('🌐 API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
              '✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('❌ API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );

    _isInitialized = true;
  }

  String? _getAuthToken() {
    // TODO: Get token from shared preferences or secure storage
    return null;
  }

  // ============================================================================
  // USER ENDPOINTS
  // ============================================================================

  /// Get current user profile
  Future<UserModel> getCurrentUser() async {
    if (useMockData) {
      // Return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      return UserModel.mockUser;
    }

    try {
      final response = await _dio.get('/user/profile');
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      debugPrint('Error fetching user: $e');
      rethrow;
    }
  }

  /// Get user by ID
  Future<UserModel> getUserById(String userId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return UserModel.mockUser;
    }

    try {
      final response = await _dio.get('/user/$userId');
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      debugPrint('Error fetching user: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserModel> updateUser(String userId, Map<String, dynamic> data) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return UserModel.mockUser.copyWith(
        name: data['name'],
        address: data['address'],
        phone: data['phone'],
      );
    }

    try {
      final response = await _dio.put('/user/$userId', data: data);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  /// Update user location
  Future<void> updateUserLocation(
      String userId, double latitude, double longitude) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    try {
      await _dio.post('/user/$userId/location', data: {
        'latitude': latitude,
        'longitude': longitude,
        'locationUpdatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating location: $e');
      rethrow;
    }
  }

  /// Get user balance
  Future<double> getUserBalance(String userId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return UserModel.mockUser.balance;
    }

    try {
      final response = await _dio.get('/user/$userId/balance');
      return (response.data['data']['balance'] as num).toDouble();
    } catch (e) {
      debugPrint('Error fetching balance: $e');
      rethrow;
    }
  }

  // ============================================================================
  // TRANSACTION ENDPOINTS
  // ============================================================================

  /// Get user transactions
  Future<List<TransactionModel>> getTransactions({
    String? userId,
    TransactionMode? mode,
    int? limit,
    int? offset,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      var transactions = TransactionModel.mockTransactions;

      // Filter by mode if specified
      if (mode != null) {
        transactions = transactions.where((t) => t.mode == mode).toList();
      }

      return transactions;
    }

    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) queryParams['userId'] = userId;
      if (mode != null) queryParams['mode'] = mode.name;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response =
          await _dio.get('/transactions', queryParameters: queryParams);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      rethrow;
    }
  }

  /// Get sent transactions
  Future<List<TransactionModel>> getSentTransactions(String userId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return TransactionModel.mockTransactions
          .where((t) => t.senderId == userId)
          .toList();
    }

    try {
      final response = await _dio.get('/user/$userId/transactions/sent');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching sent transactions: $e');
      rethrow;
    }
  }

  /// Get received transactions
  Future<List<TransactionModel>> getReceivedTransactions(String userId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return TransactionModel.mockTransactions
          .where((t) => t.receiverId == userId)
          .toList();
    }

    try {
      final response = await _dio.get('/user/$userId/transactions/received');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching received transactions: $e');
      rethrow;
    }
  }

  /// Create new transaction
  Future<TransactionModel> createTransaction({
    required String senderId,
    required String receiverId,
    required double amount,
    required TransactionMode mode,
    String? purpose,
    double? latitude,
    double? longitude,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        senderId: senderId,
        receiverId: receiverId,
        amount: amount,
        mode: mode,
        purpose: purpose,
        latitude: latitude,
        longitude: longitude,
        sentAt: DateTime.now(),
        transactedAt: DateTime.now(),
        status: 'completed',
      );
    }

    try {
      final response = await _dio.post('/transactions', data: {
        'senderId': senderId,
        'receiverId': receiverId,
        'amount': amount,
        'mode': mode.name,
        'purpose': purpose,
        'latitude': latitude,
        'longitude': longitude,
        'sentAt': DateTime.now().toIso8601String(),
      });
      return TransactionModel.fromJson(response.data['data']);
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      rethrow;
    }
  }

  /// Get monthly transaction statistics
  Future<Map<String, dynamic>> getMonthlyStats(String userId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'online': {
          'Jan': 45,
          'Feb': 52,
          'Mar': 38,
          'Apr': 60,
          'May': 55,
        },
        'offline': {
          'Jan': 12,
          'Feb': 18,
          'Mar': 15,
          'Apr': 20,
          'May': 16,
        },
        'totalOnline': 250,
        'totalOffline': 81,
      };
    }

    try {
      final response = await _dio.get('/user/$userId/stats/monthly');
      return response.data['data'];
    } catch (e) {
      debugPrint('Error fetching monthly stats: $e');
      rethrow;
    }
  }

  // ============================================================================
  // AUTHENTICATION ENDPOINTS (if needed)
  // ============================================================================

  /// Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'user': UserModel.mockUser.toJson(),
        'token': 'mock_token_123456789',
      };
    }

    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data['data'];
    } catch (e) {
      debugPrint('Error during login: $e');
      rethrow;
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'user': UserModel.mockUser.toJson(),
        'token': 'mock_token_123456789',
      };
    }

    try {
      final response = await _dio.post('/auth/register', data: userData);
      return response.data['data'];
    } catch (e) {
      debugPrint('Error during registration: $e');
      rethrow;
    }
  }
}

// Helper to print debug messages
void debugPrint(String message) {
  print('🔷 ApiService: $message');
}
