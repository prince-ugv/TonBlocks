import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:ton_blocks/app/data/services/toncenter_fee_service.dart';
import 'package:ton_blocks/app/core/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  runApp(MaterialApp(home: TonFeePage()));
}

class TonFeePage extends StatefulWidget {
  const TonFeePage({super.key});

  @override
  State<TonFeePage> createState() => _TonFeePageState();
}

class _TonFeePageState extends State<TonFeePage> {
  final toController = TextEditingController();
  final amountController = TextEditingController();
  String result = '';
  bool isLoading = false;

  Future<void> estimate() async {
    final to = toController.text.trim();
    final amount = amountController.text.trim();
    setState(() {
      isLoading = true;
      result = '';
    });
    try {
      final boc = await TonFeeService.getBoc(to, amount);
      if (boc == null) {
        setState(() {
          result =
              'Error: Could not generate BOC. Please check the address and amount.';

          isLoading = false;
        });
        return;
      }

      final fees = await TonFeeService.estimateFee(to, boc);
      if (fees == null) {
        setState(() {
          result =
              'Error: Could not estimate fee. Please check the BOC and network/API.';
          isLoading = false;
        });
        return;
      }

      double manualTotal = 0;
      try {
        manualTotal =
            (double.tryParse(fees['gas_fee'].toString()) ?? 0) +
            (double.tryParse(fees['fwd_fee'].toString()) ?? 0) +
            (double.tryParse(fees['in_fwd_fee'].toString()) ?? 0) +
            (double.tryParse(fees['storage_fee'].toString()) ?? 0);
      } catch (_) {}
      double manualTotalTon = manualTotal / 1e9;

      // Fetch TON price in USD
      double tonPrice = 0;
      try {
        final priceResponse = await http.get(
          Uri.parse(
            'https://api.coingecko.com/api/v3/simple/price?ids=the-open-network&vs_currencies=usd',
          ),
        );
        if (priceResponse.statusCode == 200) {
          final priceData = jsonDecode(priceResponse.body);
          tonPrice = (priceData['the-open-network']?['usd'] ?? 0).toDouble();
        }
      } catch (_) {}
      double totalUsd = manualTotalTon * tonPrice;
      setState(() {
        result =
            '''
Gas Fee: ${fees['gas_fee']}
Fwd Fee: ${fees['fwd_fee']}
In Fwd Fee: ${fees['in_fwd_fee']}
Storage: ${fees['storage_fee']}
Total: ${manualTotalTon.toStringAsFixed(4)} TON ~ ${totalUsd.toStringAsFixed(4)} USD
''';
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        result = 'Your Backend Connection Lost !';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove backgroundColor to allow gradient background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: AppTheme.backgroundColor),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Estimate TON Transaction Fee',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: toController,
                style: const TextStyle(color: Colors.white70),
                decoration: InputDecoration(
                  labelText: 'To Address',
                  labelStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: amountController,
                style: const TextStyle(color: Colors.white70),
                decoration: InputDecoration(
                  labelText: 'Amount in TON',
                  labelStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(
                    Icons.currency_bitcoin_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: estimate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          65,
                          199,
                          150,
                        ),
                        foregroundColor: AppTheme.backgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Estimate Fee'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          result = '';
                          toController.clear();
                          amountController.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Shimmer.fromColors(
                    baseColor: Colors.white24,
                    highlightColor: Colors.white54,
                    child: Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )
              else if (result.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    result,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
