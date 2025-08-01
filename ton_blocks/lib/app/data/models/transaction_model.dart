class Transaction {
  final String hash;
  final String from;
  final String to;
  final String amount;
  final DateTime timestamp;
  final String status;
  final String? fee;
  final String? comment;
  final int blockSeqno;
  final int lt; // For pagination

  Transaction({
    required this.hash,
    required this.from,
    required this.to,
    required this.amount,
    required this.timestamp,
    required this.status,
    this.fee,
    this.comment,
    required this.blockSeqno,
    required this.lt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Handle TONAPI v2 event format
    final event = json;
    final actions = (event['actions'] as List?) ?? [];
    
    String from = '';
    String to = '';
    String amount = '0';
    String? comment;
    
    // Extract transaction details from actions
    if (actions.isNotEmpty) {
      final action = actions.first;
      final actionType = action['type'] ?? '';
      
      if (actionType == 'TonTransfer') {
        final tonTransfer = action['TonTransfer'] ?? {};
        from = tonTransfer['sender']?['address'] ?? '';
        to = tonTransfer['recipient']?['address'] ?? '';
        amount = tonTransfer['amount']?.toString() ?? '0';
        comment = tonTransfer['comment'];
      } else if (actionType == 'JettonTransfer') {
        final jettonTransfer = action['JettonTransfer'] ?? {};
        from = jettonTransfer['sender']?['address'] ?? '';
        to = jettonTransfer['recipient']?['address'] ?? '';
        amount = jettonTransfer['amount']?.toString() ?? '0';
        comment = jettonTransfer['comment'];
        
        // For Jetton transfers, also include the jetton name in the comment if available
        final jetton = jettonTransfer['jetton'];
        if (jetton != null) {
          final jettonName = jetton['name'] ?? jetton['symbol'] ?? 'Token';
          comment = comment?.isNotEmpty == true 
              ? '$comment ($jettonName)' 
              : jettonName;
        }
      }
    }
    
    // Convert address format from 0: to EQ format for display
    if (from.startsWith('0:')) {
      from = 'EQ${from.substring(2)}';
    }
    if (to.startsWith('0:')) {
      to = 'EQ${to.substring(2)}';
    }
    
    return Transaction(
      hash: event['event_id'] ?? '',
      from: from,
      to: to,
      amount: amount,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((event['timestamp'] ?? 0) * 1000).toInt(),
      ),
      status: event['in_progress'] == true ? 'pending' : 'success',
      fee: event['fee']?['total']?.toString(),
      comment: comment,
      blockSeqno: event['lt']?.toInt() ?? 0,
      lt: event['lt']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'from': from,
      'to': to,
      'amount': amount,
      'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
      'status': status,
      'fee': fee,
      'comment': comment,
      'block_seqno': blockSeqno,
      'lt': lt,
    };
  }
}

class WalletInfo {
  final String address;
  final String balance;
  final String status;
  final String lastTransactionHash;

  WalletInfo({
    required this.address,
    required this.balance,
    required this.status,
    required this.lastTransactionHash,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      address: json['address']?.toString() ?? '',
      balance: json['balance']?.toString() ?? '0',
      status: json['status']?.toString() ?? 'unknown',
      lastTransactionHash: json['last_transaction_hash']?.toString() ?? '',
    );
  }
}
