import 'package:get/get.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/services/ton_api_service.dart';
import 'package:flutter/services.dart';

class TransactionDetailController extends GetxController {
  final TonApiService _tonApiService = Get.find<TonApiService>();
  
  // Observables
  final Rx<Transaction?> transaction = Rx<Transaction?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Transaction?> detailedTransaction = Rx<Transaction?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    _loadTransactionDetails();
  }

  void _loadArguments() {
    final args = Get.arguments;
    if (args is Transaction) {
      transaction.value = args;
      detailedTransaction.value = args; // Initialize with basic data
    }
  }

  Future<void> _loadTransactionDetails() async {
    if (transaction.value == null) {
      errorMessage.value = 'No transaction data provided';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Get additional transaction details from API if needed
      final details = await _tonApiService.getTransactionDetails(
        transaction.value!.hash,
      );
      
      if (details != null) {
        detailedTransaction.value = details;
      }
    } catch (e) {
      errorMessage.value = 'Error loading transaction details: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
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

  String getFullAddress(String address) {
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

  String getFormattedDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Text copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void refresh() {
    _loadTransactionDetails();
  }
}
