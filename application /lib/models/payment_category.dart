import 'package:flutter/material.dart';

// Payment Category Model
class PaymentCategory {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final List<String> services;

  PaymentCategory({
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.services,
  });
}

// USA Payment Categories
final List<PaymentCategory> paymentCategories = [
  // Money Transfer
  PaymentCategory(
    title: 'Money Transfer',
    icon: Icons.swap_horiz,
    gradientColors: [Color(0xFF00D9FF), Color(0xFF0A84FF)],
    services: ['Send Money', 'Request Money', 'Withdraw', 'Cash Out'],
  ),

  // Banking
  PaymentCategory(
    title: 'Banking',
    icon: Icons.account_balance,
    gradientColors: [Color(0xFF7B61FF), Color(0xFF0A84FF)],
    services: [
      'Bank Transfer',
      'Direct Deposit',
      'Wire Transfer',
      'ACH Payment'
    ],
  ),

  // Utilities
  PaymentCategory(
    title: 'Utilities',
    icon: Icons.bolt,
    gradientColors: [Color(0xFF00FF88), Color(0xFF00CC70)],
    services: ['Electricity', 'Water', 'Gas', 'Internet', 'Phone', 'Cable TV'],
  ),

  // Bills & Payments
  PaymentCategory(
    title: 'Bills',
    icon: Icons.receipt_long,
    gradientColors: [Color(0xFFFF9500), Color(0xFFFF6B00)],
    services: ['Credit Card', 'Loan Payment', 'Rent', 'Mortgage', 'HOA Fees'],
  ),

  // Government
  PaymentCategory(
    title: 'Government',
    icon: Icons.gavel,
    gradientColors: [Color(0xFFFF006E), Color(0xFFCC0057)],
    services: [
      'Traffic Fines',
      'Court Fees',
      'Tax Payment',
      'Parking Tickets',
      'DMV Fees'
    ],
  ),

  // Travel
  PaymentCategory(
    title: 'Travel',
    icon: Icons.flight,
    gradientColors: [Color(0xFF00D9FF), Color(0xFF7B61FF)],
    services: [
      'Airlines',
      'Hotels',
      'Car Rental',
      'Travel Insurance',
      'Visa Fees'
    ],
  ),

  // Insurance
  PaymentCategory(
    title: 'Insurance',
    icon: Icons.security,
    gradientColors: [Color(0xFF0A84FF), Color(0xFF7B61FF)],
    services: ['Health', 'Auto', 'Life', 'Home', 'Dental', 'Vision'],
  ),

  // Finance
  PaymentCategory(
    title: 'Finance',
    icon: Icons.trending_up,
    gradientColors: [Color(0xFF00FF88), Color(0xFF00D9FF)],
    services: ['Investments', 'Stocks', 'Crypto', 'Mutual Funds', '401k'],
  ),

  // Education
  PaymentCategory(
    title: 'Education',
    icon: Icons.school,
    gradientColors: [Color(0xFFFF9500), Color(0xFF7B61FF)],
    services: ['Tuition', 'Student Loans', 'Books', 'School Fees', 'Courses'],
  ),

  // Healthcare
  PaymentCategory(
    title: 'Healthcare',
    icon: Icons.local_hospital,
    gradientColors: [Color(0xFFFF006E), Color(0xFFFF9500)],
    services: ['Doctor Bills', 'Pharmacy', 'Lab Tests', 'Hospital', 'Dental'],
  ),

  // Subscriptions
  PaymentCategory(
    title: 'Subscriptions',
    icon: Icons.autorenew,
    gradientColors: [Color(0xFF7B61FF), Color(0xFFFF006E)],
    services: ['Streaming', 'Music', 'News', 'Apps', 'Cloud Storage', 'Gym'],
  ),

  // Shopping
  PaymentCategory(
    title: 'Shopping',
    icon: Icons.shopping_bag,
    gradientColors: [Color(0xFF00FF88), Color(0xFFFF9500)],
    services: [
      'Online Store',
      'Grocery',
      'Electronics',
      'Clothing',
      'Home Goods'
    ],
  ),
];
