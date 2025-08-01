import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/ton_api_service.dart';

class ApiTestView extends StatefulWidget {
  const ApiTestView({super.key});

  @override
  State<ApiTestView> createState() => _ApiTestViewState();
}

class _ApiTestViewState extends State<ApiTestView> {
  final TonApiService _apiService = Get.find<TonApiService>();
  final TextEditingController _addressController = TextEditingController();
  
  String _result = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test TON API Connection',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'TON Address',
                hintText: 'Enter a TON wallet address...',
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testMasterchainInfo,
                  child: const Text('Test Masterchain'),
                ),
                SizedBox(width: 16.w),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testAddressInfo,
                  child: const Text('Test Address'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _result.isEmpty ? 'Results will appear here...' : _result,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testMasterchainInfo() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final blocks = await _apiService.getLatestBlocks();
      setState(() {
        _result = 'Success! Latest blocks:\n${blocks.toString()}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAddressInfo() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(() {
        _result = 'Please enter an address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final wallet = await _apiService.getWalletInfo(address);
      if (wallet != null) {
        setState(() {
          _result = 'Success! Wallet info:\n'
              'Address: ${wallet.address}\n'
              'Balance: ${_apiService.formatTonAmount(wallet.balance)} TON\n'
              'Status: ${wallet.status}\n'
              'Last TX Hash: ${wallet.lastTransactionHash}';
        });
      } else {
        setState(() {
          _result = 'Wallet not found or error occurred';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
