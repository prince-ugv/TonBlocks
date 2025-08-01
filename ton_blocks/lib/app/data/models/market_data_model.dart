class MarketData {
  final String symbol;
  final double price;
  final double priceChangePercentage24h;
  final double marketCap;
  final double volume24h;
  final int marketCapRank;
  final double? circulatingSupply;
  final double? totalSupply;
  final double? ath;
  final double? atl;
  final DateTime lastUpdated;

  MarketData({
    required this.symbol,
    required this.price,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.volume24h,
    required this.marketCapRank,
    this.circulatingSupply,
    this.totalSupply,
    this.ath,
    this.atl,
    required this.lastUpdated,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      symbol: json['symbol']?.toString().toUpperCase() ?? 'TON',
      price: (json['current_price'] ?? 0).toDouble(),
      priceChangePercentage24h: (json['price_change_percentage_24h'] ?? 0).toDouble(),
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      volume24h: (json['total_volume'] ?? 0).toDouble(),
      marketCapRank: (json['market_cap_rank'] ?? 0).toInt(),
      circulatingSupply: json['circulating_supply']?.toDouble(),
      totalSupply: json['total_supply']?.toDouble(),
      ath: json['ath']?.toDouble(),
      atl: json['atl']?.toDouble(),
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'current_price': price,
      'price_change_percentage_24h': priceChangePercentage24h,
      'market_cap': marketCap,
      'total_volume': volume24h,
      'market_cap_rank': marketCapRank,
      'circulating_supply': circulatingSupply,
      'total_supply': totalSupply,
      'ath': ath,
      'atl': atl,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // Helper methods for formatting
  String get formattedPrice => '\$${price.toStringAsFixed(4)}';
  
  String get formattedMarketCap {
    if (marketCap >= 1e9) {
      return '\$${(marketCap / 1e9).toStringAsFixed(2)}B';
    } else if (marketCap >= 1e6) {
      return '\$${(marketCap / 1e6).toStringAsFixed(2)}M';
    } else if (marketCap >= 1e3) {
      return '\$${(marketCap / 1e3).toStringAsFixed(2)}K';
    }
    return '\$${marketCap.toStringAsFixed(2)}';
  }

  String get formattedVolume {
    if (volume24h >= 1e9) {
      return '\$${(volume24h / 1e9).toStringAsFixed(2)}B';
    } else if (volume24h >= 1e6) {
      return '\$${(volume24h / 1e6).toStringAsFixed(2)}M';
    } else if (volume24h >= 1e3) {
      return '\$${(volume24h / 1e3).toStringAsFixed(2)}K';
    }
    return '\$${volume24h.toStringAsFixed(2)}';
  }

  String get formattedPriceChange {
    String sign = priceChangePercentage24h >= 0 ? '+' : '';
    return '$sign${priceChangePercentage24h.toStringAsFixed(2)}%';
  }

  bool get isPricePositive => priceChangePercentage24h >= 0;
}
