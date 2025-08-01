import 'package:get/get.dart';
import 'dart:async';
import '../../../data/models/transaction_model.dart';
import '../../../data/services/ton_api_service.dart';
import '../../../core/utils/ton_utils.dart';

class HomeController extends GetxController {
  // NFT Checker state
  final RxList<Map<String, dynamic>> nftItems = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingNfts = false.obs;
  final TonApiService _tonApiService = Get.find<TonApiService>();

  // UI callbacks
  Function()? _clearSearchFieldCallback;
  
  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isLoadingTransactions = false.obs;
  final RxBool isLoadingPrice = false.obs;
  final RxString searchAddress = ''.obs;
  final RxList<Transaction> recentTransactions = <Transaction>[].obs;
  final RxList<Map<String, dynamic>> latestBlocks = <Map<String, dynamic>>[].obs;
  final Rx<WalletInfo?> walletInfo = Rx<WalletInfo?>(null);
  final RxString errorMessage = ''.obs;
  final RxString tonPrice = '0.00'.obs;
  final RxString priceChange = '0.00'.obs;
  final RxBool isPricePositive = true.obs;
  final RxInt totalTransactionCount = 0.obs;
  
  // Timers for auto-refresh
  Timer? _priceTimer;
  Timer? _transactionsTimer;
  Timer? _walletBalanceTimer;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _priceTimer?.cancel();
    _transactionsTimer?.cancel();
    _walletBalanceTimer?.cancel();
    super.onClose();
  }

  void _startAutoRefresh() {
    // Refresh TON price every 1 minute
    _priceTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _loadTonPrice();
    });

    // Refresh transactions every 1 minute (only if address is searched)
    _transactionsTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (searchAddress.value.isNotEmpty) {
        _loadRecentTransactionsForAddress(searchAddress.value);
        _loadTotalTransactionCount(searchAddress.value);
      }
    });
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadLatestBlocks(),
      _loadTonPrice(),
    ]);
    // Don't load default transactions - only load when user searches
  }

  Future<void> _loadTonPrice() async {
    try {
      isLoadingPrice.value = true;
      final priceData = await _tonApiService.getTonPrice();
      
      if (priceData['price'] != null) {
        final price = double.tryParse(priceData['price'].toString()) ?? 0.0;
        tonPrice.value = price.toStringAsFixed(4);
      }
      
      if (priceData['change_24h'] != null) {
        final change = double.tryParse(priceData['change_24h'].toString()) ?? 0.0;
        priceChange.value = change.abs().toStringAsFixed(2);
        isPricePositive.value = change >= 0;
      }
    } catch (e) {
      // Set default values on error
      tonPrice.value = 'N/A';
      priceChange.value = '0.00';
    } finally {
      isLoadingPrice.value = false;
    }
  }

  Future<void> _loadRecentTransactionsForAddress(String address) async {
    try {
      isLoadingTransactions.value = true;
      final transactions = await _tonApiService.getTransactions(address: address, limit: 4);
      recentTransactions.value = transactions;
    } catch (e) {
      recentTransactions.value = [];
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  Future<void> _loadLatestBlocks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final blocks = await _tonApiService.getLatestBlocks(limit: 5);
      latestBlocks.value = blocks;
    } catch (e) {
      errorMessage.value = 'Failed to load latest blocks: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTotalTransactionCount(String address) async {
    try {
      // Get a larger number of transactions to get total count
      // Most APIs return the total count in metadata or we can estimate
      final transactions = await _tonApiService.getTransactions(address: address, limit: 100);
      totalTransactionCount.value = transactions.length;
      
      // If we got exactly 100, there might be more, so we'll show 100+
      // In a real implementation, you'd use an API that returns total count
    } catch (e) {
      totalTransactionCount.value = 0;
    }
  }

  Future<void> searchWallet(String address) async {
    
    if (address.isEmpty) {
      errorMessage.value = 'Please enter a wallet address';
      return;
    }

    if (!_tonApiService.isValidTonAddress(address)) {
      errorMessage.value = 'Invalid TON address format';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      searchAddress.value = address;
      
      // Get wallet info
      final wallet = await _tonApiService.getWalletInfo(address);
      walletInfo.value = wallet;
      // Fetch NFTs for this address
      await fetchNftsForAddress(address);
      
      // Get recent transactions and total count for this address
      await Future.wait([
        _loadRecentTransactionsForAddress(address),
        _loadTotalTransactionCount(address),
      ]);
      
      if (wallet == null) {
        errorMessage.value = 'Wallet not found or inactive';
      } else {
        // Start wallet balance auto-refresh when wallet is successfully loaded
        _startWalletBalanceRefresh();
      }
    } catch (e) {
      errorMessage.value = 'Error searching wallet: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchWalletFromUI(String address) async {
    await searchWallet(address.trim());
    // Keyboard dismissal is handled in the UI layer
  }

  void navigateToTransactions() {
    Get.toNamed('/transactions', arguments: {
      'address': searchAddress.value,
      'walletInfo': walletInfo.value,
    });
  }

  void navigateToTransactionDetail(Transaction transaction) {
    // Dismiss keyboard before navigation
    Get.focusScope?.unfocus();
    Get.toNamed('/transaction-detail', arguments: transaction);
  }

  // Set callback for clearing search field in UI
  void setClearSearchFieldCallback(Function()? callback) {
    _clearSearchFieldCallback = callback;
  }

  void clearSearch() {
    searchAddress.value = '';
    walletInfo.value = null;
    errorMessage.value = '';
    recentTransactions.clear(); // Clear transactions when clearing search
    totalTransactionCount.value = 0; // Reset total transaction count
    // Cancel wallet balance timer when search is cleared
    _walletBalanceTimer?.cancel();
    // Reset loading states
    isLoading.value = false;
    isLoadingTransactions.value = false;
    // Clear NFT state
    nftItems.clear();
    isLoadingNfts.value = false;
    
    // Clear UI search field if callback is available
    _clearSearchFieldCallback?.call();
  }

  void refreshData() {
    _loadInitialData();
    if (searchAddress.value.isNotEmpty) {
      _loadRecentTransactionsForAddress(searchAddress.value);
      _loadTotalTransactionCount(searchAddress.value);
      _refreshWalletBalance(); // Also refresh wallet balance on manual refresh
    }
    _loadTonPrice();
  }

  Future<void> _refreshWalletBalance() async {
    try {
      if (searchAddress.value.isEmpty) return;
      
      // Get updated wallet info without showing loading indicator
      final wallet = await _tonApiService.getWalletInfo(searchAddress.value);
      if (wallet != null) {
        walletInfo.value = wallet;
      }
    } catch (e) {
      print('Failed to refresh wallet balance: $e');
      // Don't update error message for automatic refresh to avoid UI disruption
    }
  }

  void _startWalletBalanceRefresh() {
    // Cancel any existing wallet balance timer
    _walletBalanceTimer?.cancel();
    
    // Start a new timer for wallet balance refresh every 1 minute
    _walletBalanceTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (walletInfo.value != null && searchAddress.value.isNotEmpty) {
        _refreshWalletBalance();
      }
    });
  }

  // Helper methods
  // Fetch NFTs for a given address
  Future<void> fetchNftsForAddress(String address) async {
    if (address.isEmpty) {
      nftItems.clear();
      return;
    }
    try {
      isLoadingNfts.value = true;
      // Example API call, replace with your actual NFT API endpoint and parsing logic
      final nfts = await _tonApiService.getNfts(address);
      nftItems.assignAll(nfts.cast<Map<String, dynamic>>());
        } catch (e) {
      print('Failed to fetch NFTs: $e');
      nftItems.clear();
    } finally {
      isLoadingNfts.value = false;
    }
  }
  String formatAmount(String amount) {
    return _tonApiService.formatTonAmount(amount);
  }

  String formatAddress(String address) {
    return TonUtils.formatAddress(address);
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
