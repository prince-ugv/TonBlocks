import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/transactions/bindings/transactions_binding.dart';
import '../modules/transactions/views/transactions_view.dart';
import '../modules/transaction_detail/bindings/transaction_detail_binding.dart';
import '../modules/transaction_detail/views/transaction_detail_view.dart';
import '../modules/api_test/views/api_test_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),
    GetPage(
      name: AppRoutes.transactionDetail,
      page: () => const TransactionDetailView(),
      binding: TransactionDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.apiTest,
      page: () => const ApiTestView(),
      binding: HomeBinding(), // Reuse home binding for API service
    ),
  ];
}
