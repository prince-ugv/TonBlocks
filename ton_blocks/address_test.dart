
// Simple test to verify TON address format validation
void main() {
  print('Testing TON Address Format Validation...\n');
  
  // Test addresses
  List<String> testAddresses = [
    'EQBvW8Z5huBkMJYdnfAEM5JqTNkuJmt0aR4CP-oQsJVwC7zO', // Valid EQ
    'UQBvW8Z5huBkMJYdnfAEM5JqTNkuJmt0aR4CP-oQsJVwC7zO', // Valid UQ
    'EQD2NmD_lH5f5u1Kj3KfGyTvhZSX0Eg6qp2a4u6_4vPmrDVs', // Valid EQ
    'UQD2NmD_lH5f5u1Kj3KfGyTvhZSX0Eg6qp2a4u6_4vPmrDVs', // Valid UQ
    '0:3ed6d83ff947e5fe6ed4a8f729f1b24ef8594971e0483aaa9d9ae2eebfe2f3e6ac35b', // Valid 0: format
    'EQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM9c', // Zero address EQ
    'UQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM9c', // Zero address UQ
    'invalid_address', // Invalid
    'EQ', // Too short
    '', // Empty
  ];
  
  for (String address in testAddresses) {
    bool isValid = isValidTonAddress(address);
    List<String> formats = getAddressFormats(address);
    
    print('Address: $address');
    print('  Valid: $isValid');
    print('  Formats to try: $formats');
    print('');
  }
}

// TON address validation function
bool isValidTonAddress(String address) {
  if (address.isEmpty) return false;
  address = address.trim();
  
  // TON addresses can be in EQ or UQ format with 48 characters after prefix
  final tonAddressRegex = RegExp(r'^[EUu][Qq][A-Za-z0-9_-]{46}$');
  
  // Also accept 0: format addresses
  final zeroFormatRegex = RegExp(r'^0:[A-Fa-f0-9]{64}$');
  
  // Accept raw 48-character addresses (without prefix)
  final rawAddressRegex = RegExp(r'^[A-Za-z0-9_-]{48}$');
  
  return tonAddressRegex.hasMatch(address) || 
         zeroFormatRegex.hasMatch(address) ||
         rawAddressRegex.hasMatch(address);
}

// Generate different address formats to try
List<String> getAddressFormats(String address) {
  List<String> formats = [];
  address = address.trim();
  
  // Add original address
  formats.add(address);
  
  if (address.startsWith('UQ')) {
    // Try EQ format (simple replacement)
    formats.add('EQ${address.substring(2)}');
  } else if (address.startsWith('EQ')) {
    // Try UQ format (simple replacement)  
    formats.add('UQ${address.substring(2)}');
  }
  
  if (address.startsWith('0:')) {
    // Try EQ format
    formats.add('EQ${address.substring(2)}');
    // Try UQ format
    formats.add('UQ${address.substring(2)}');
  }
  
  // If it's 48 characters, try with prefixes
  if (address.length == 48 && RegExp(r'^[A-Za-z0-9_-]{48}$').hasMatch(address)) {
    formats.add('EQ$address');
    formats.add('UQ$address');
    formats.add('0:${address.toLowerCase()}');
  }
  
  // Remove duplicates while preserving order
  return formats.toSet().toList();
}
