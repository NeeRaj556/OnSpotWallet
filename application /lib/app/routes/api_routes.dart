abstract class ApiRoutes {
  static const String baseUrl = "http://localhost:3030/api";

  // Auth routes
  static const String login = "/login";
  static const String register = "/register";
  static const String pinUpdate = "/pinUpdate";

  // User routes
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
