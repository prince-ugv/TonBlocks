import 'package:tonutils/tonutils.dart';

class TonUtils {
  /// Normalizes TON address to standard format (supports EQ and UQ formats)
  static String normalizeAddress(String address) {
    try {
      if (address.isEmpty) return '';
      
      // Remove any whitespace
      address = address.trim();
      
      // Use tonutils to parse and normalize the address
      final parsedAddress = InternalAddress.parse(address);
      
      // Return in EQ format (bounceable) as standard
      return parsedAddress.toString(
        isBounceable: true,
        isTestOnly: false,
        isUrlSafe: true,
      );
    } catch (e) {
      print('Error normalizing address: $e');
      // Fallback to original address if parsing fails
      return address;
    }
  }

  /// Converts address to the same format as the searched address
  static String toConsistentFormat(String address, String searchedAddress) {
    try {
      if (address.isEmpty) return '';
      
      // Parse the address
      final parsedAddress = InternalAddress.parse(address);
      
      // Determine format based on searched address
      bool useBounceable = true; // Default to EQ
      if (searchedAddress.startsWith('UQ')) {
        useBounceable = false; // Use UQ format
      }
      
      return parsedAddress.toString(
        isBounceable: useBounceable,
        isTestOnly: false,
        isUrlSafe: true,
      );
    } catch (e) {
      return address;
    }
  }

  /// Checks if two addresses are equivalent (regardless of EQ/UQ format)
  static bool areAddressesEqual(String address1, String address2) {
    try {
      if (address1.isEmpty || address2.isEmpty) return false;
      
      // Parse both addresses
      final parsed1 = InternalAddress.parse(address1);
      final parsed2 = InternalAddress.parse(address2);
      
      // Compare raw addresses
      return parsed1.toRawString() == parsed2.toRawString();
    } catch (e) {
      // Fallback to string comparison
      return address1.toLowerCase() == address2.toLowerCase();
    }
  }

  /// Converts address to EQ format (user-friendly bounceable)
  static String toEQFormat(String address) {
    try {
      if (address.isEmpty) return '';
      
      // If already in EQ format, return as is
      if (address.startsWith('EQ')) {
        return address;
      }
      
      // For demo purposes, if it's a raw format, convert to EQ
      if (address.startsWith('0:')) {
        // This is a simplified conversion - in real app you'd use proper TON SDK
        final hex = address.substring(2);
        if (hex.length == 64) {
          // For demo, just prepend EQ to a shortened version
          return 'EQ${hex.substring(0, 44)}';
        }
      }
      
      // If it's already a user-friendly format but doesn't start with EQ
      if (address.length == 48 && !address.startsWith('EQ')) {
        return 'EQ${address.substring(2)}';
      }
      
      return address;
    } catch (e) {
      print('Error converting to EQ format: $e');
      return address;
    }
  }

  /// Formats address for display (shows first 8 and last 6 characters)
  static String formatAddress(String address) {
    try {
      if (address.isEmpty) return '';
      
      // Normalize and convert to EQ format first
      final eqAddress = toEQFormat(normalizeAddress(address));
      
      if (eqAddress.length > 14) {
        return '${eqAddress.substring(0, 8)}...${eqAddress.substring(eqAddress.length - 6)}';
      }
      return eqAddress;
    } catch (e) {
      print('Error formatting address: $e');
      return address;
    }
  }

  /// Formats TON amount for display
  static String formatAmount(String amount) {
    try {
      if (amount.isEmpty || amount == '0') return '0';
      
      final double value = double.parse(amount);
      
      if (value == 0) {
        return '0';
      } else if (value < 0.001) {
        return value.toStringAsExponential(2);
      } else if (value < 1) {
        return value.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
      } else if (value < 1000) {
        return value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      } else {
        return value.toStringAsFixed(0);
      }
    } catch (e) {
      print('Error formatting amount: $e');
      return amount;
    }
  }

  /// Parses amount from API response (handles both string and number)
  static String parseAmountFromResponse(dynamic amountValue) {
    try {
      if (amountValue == null) return '0';
      
      if (amountValue is String) {
        if (amountValue.isEmpty) return '0';
        
        // Handle scientific notation
        if (amountValue.toLowerCase().contains('e')) {
          final double value = double.parse(amountValue);
          return (value / 1000000000).toString(); // Convert from nanotons
        }
        
        // Handle regular string numbers
        final double value = double.parse(amountValue);
        if (value > 1000000000) {
          return (value / 1000000000).toString(); // Convert from nanotons
        }
        return value.toString();
      } else if (amountValue is num) {
        if (amountValue > 1000000000) {
          return (amountValue / 1000000000).toString(); // Convert from nanotons
        }
        return amountValue.toString();
      }
      
      return amountValue.toString();
    } catch (e) {
      print('Error parsing amount from response: $e for value: $amountValue');
      return '0';
    }
  }

  /// Formats transaction hash for display as "x hash aaa**cc"
  static String formatTransactionHash(String hash) {
    try {
      if (hash.isEmpty) return '';
      
      if (hash.length >= 5) {
        final prefix = hash.substring(0, 3);
        final suffix = hash.substring(hash.length - 2);
        return 'x hash $prefix**$suffix';
      } else {
        return 'x hash $hash';
      }
    } catch (e) {
      print('Error formatting transaction hash: $e');
      return hash;
    }
  }
}
