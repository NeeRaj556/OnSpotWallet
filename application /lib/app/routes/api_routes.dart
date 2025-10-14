abstract class ApiRoutes {
  static const String baseUrl = "https://93h6gxfb-3030.inc1.devtunnels.ms/api";

  // Auth routes
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String pinUpdate = "/auth/pinUpdate";

  // User routes
  static const String userMe = "/user/me";
  static const String userProfile = "/user/profile";
  static const String userBalance = "/user/balance";
  static const String userUpdate = "/user/update";

  // Transaction routes
  static const String transactions = "/transactions";
  static const String transactionById = "/transactions/:id";
  static const String sendTransaction = "/transactions/send";
  static const String transactionHistory = "/transactions/history";
  static const String monthlyStats = "/transactions/stats/monthly";
}
