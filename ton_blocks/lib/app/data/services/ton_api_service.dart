import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../../core/utils/ton_utils.dart';

class TonApiService extends GetxService {
  late Dio _dio;
  
  // TON Console API endpoints and key
  static const String _baseUrl = 'https://tonapi.io';
  static const String _apiKey = 'AE7BU37RNDBGY7QAAAAL2TV3QYW36NCP7ZRDJOZQCCGCNCVW5UKYZKBG5DZA7FAEAFXN5AI';
  
  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
    ));
    
  }

  // Normalize address for API compatibility (accepts both EQ and UQ)
  String _normalizeAddressForAPI(String address) {
    try {
      // Use TonUtils to normalize the address
      return TonUtils.normalizeAddress(address);
    } catch (e) {
      print('Error normalizing address for API: $e');
      // Fallback: convert UQ to EQ if needed
      if (address.startsWith('UQ')) {
        return 'EQ${address.substring(2)}';
      }
      return address;
    }
  }

  // Get wallet information
  Future<WalletInfo?> getWalletInfo(String address) async {
    try {
      final convertedAddress = _normalizeAddressForAPI(address);
      final response = await _dio.get('/v2/accounts/$convertedAddress');
      
      if (response.statusCode == 200) {
        return WalletInfo.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error getting wallet info: $e');
      return null;
    }
  }

  // Get transactions for an address
  Future<List<Transaction>> getTransactions({
    required String address,
    int limit = 20,
    String? beforeLt,
  }) async {
    try {
      final convertedAddress = _normalizeAddressForAPI(address);
      final queryParams = {
        'limit': limit.toString(),
      };
      
      if (beforeLt != null) {
        queryParams['before_lt'] = beforeLt;
      }

      final response = await _dio.get(
        '/v2/accounts/$convertedAddress/events',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> events = data['events'] ?? [];
        
        List<Transaction> transactions = [];
        for (var event in events) {
          try {
            final transaction = Transaction.fromJson(event);
            transactions.add(transaction);
          } catch (e) {
            // Skip transactions that can't be parsed
            continue;
          }
        }
        
        return transactions;
      }
      return [];
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  // Get transaction details by hash
  Future<Transaction?> getTransactionDetails(String hash) async {
    try {
      final response = await _dio.get('/v2/events/$hash');
      
      if (response.statusCode == 200) {
        return Transaction.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error getting transaction details: $e');
      return null;
    }
  }

  // Get latest blocks
  Future<List<Map<String, dynamic>>> getLatestBlocks({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/v2/blockchain/masterchain-head',
      );
      
      if (response.statusCode == 200) {
        return [response.data];
      }
      return [];
    } catch (e) {
      print('Error getting latest blocks: $e');
      return [];
    }
  }

  // Validate TON address (accepts both UQ and EQ formats)
  bool isValidTonAddress(String address) {
    // Basic TON address validation for both EQ and UQ formats
    if (address.isEmpty) return false;
    
    // TON addresses can be in EQ or UQ format with 48 characters after prefix
    final tonAddressRegex = RegExp(r'^[EUu][Qq][A-Za-z0-9_-]{46}$');
    return tonAddressRegex.hasMatch(address) || address.length == 48;
  }

  // Format TON amount (from nanotons to TON)
  String formatTonAmount(String nanotons) {
    try {
      final amount = double.parse(nanotons);
      final tonAmount = amount / 1000000000; // 1 TON = 1 B nanotons
      return tonAmount.toStringAsFixed(4);
    } catch (e) {
      return '0.0000';
    }
  }

  // Get TON price from CoinGecko API
  Future<Map<String, dynamic>> getTonPrice() async {
    try {
      final priceResponse = await Dio().get(
        'https://api.coingecko.com/api/v3/simple/price',
        queryParameters: {
          'ids': 'the-open-network',
          'vs_currencies': 'usd',
          'include_24hr_change': 'true'
        },
      );
      if (priceResponse.statusCode == 200) {
        final data = priceResponse.data['the-open-network'];
        double price = 0.0;
        double change = 0.0;
        if (data != null) {
          if (data['usd'] != null) {
            price = double.tryParse(data['usd'].toString()) ?? 0.0;
          }
          if (data['usd_24h_change'] != null) {
            change = double.tryParse(data['usd_24h_change'].toString()) ?? 0.0;
          }
        }
        return {
          'price': price.toStringAsFixed(4),
          'change_24h': change.toStringAsFixed(2),
        };
      }
    } catch (e) {
      print('Error fetching TON price: $e');
    }
    return {
      'price': '0.00',
      'change_24h': '0.00',
    };
  }

  // Get NFTs for a given address
  Future<List<Map<String, dynamic>>> getNfts(String address) async {
    try {
      final convertedAddress = _normalizeAddressForAPI(address);
      final response = await _dio.get('/v2/accounts/$convertedAddress/nfts');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('nft_items')) {
          final nfts = data['nft_items'];
          if (nfts is List) {
            return nfts.cast<Map<String, dynamic>>();
          }
        }
      }
      return [];
    } catch (e) {
      print('Error fetching NFTs: $e');
      return [];
    }
  }
}
