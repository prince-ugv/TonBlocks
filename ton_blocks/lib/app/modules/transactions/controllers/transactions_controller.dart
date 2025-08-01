import 'package:get/get.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/services/ton_api_service.dart';

class TransactionsController extends GetxController {
  final TonApiService _tonApiService = Get.find<TonApiService>();
  
  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxString address = ''.obs;
  final Rx<WalletInfo?> walletInfo = Rx<WalletInfo?>(null);
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;
  
  // Pagination
  int? lastLt;
  final int limit = 20;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    _loadTransactions();
  }

  void _loadArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      address.value = args['address'] ?? '';
      walletInfo.value = args['walletInfo'];
    }
  }

  Future<void> _loadTransactions() async {
    if (address.value.isEmpty) {
      errorMessage.value = 'No address provided';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      
      final result = await _tonApiService.getTransactions(
        address: address.value,
        limit: limit,
      );
      
      
      transactions.clear(); // Clear existing transactions
      transactions.addAll(result); // Add new transactions
      
      
      if (result.isEmpty) {
        errorMessage.value = 'No transactions found for this address';
        hasMore.value = false;
      } else {
        hasMore.value = result.length == limit;
        if (result.isNotEmpty) {
          lastLt = result.last.lt;
        }
      }
    } catch (e) {
      errorMessage.value = 'Error loading transactions: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreTransactions() async {
    if (isLoadingMore.value || !hasMore.value || address.value.isEmpty) return;

    try {
      isLoadingMore.value = true;
      
      final result = await _tonApiService.getTransactions(
        address: address.value,
        limit: limit,
        beforeLt: lastLt?.toString(),
      );
      
      if (result.isNotEmpty) {
        transactions.addAll(result);
        hasMore.value = result.length == limit;
        lastLt = result.last.lt;
      } else {
        hasMore.value = false;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshTransactions() async {
    lastLt = null;
    hasMore.value = true;
    await _loadTransactions();
  }

  void navigateToTransactionDetail(Transaction transaction) {
    Get.toNamed('/transaction-detail', arguments: transaction);
  }

  // Helper methods
  String formatAmount(String amount) {
    return _tonApiService.formatTonAmount(amount);
  }

  String formatAddress(String address) {
    if (address.length > 10) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }
    return address;
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
