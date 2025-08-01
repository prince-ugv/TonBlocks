import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/common_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


class WalletScannerPage extends StatelessWidget {
  final dynamic controller;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;

  const WalletScannerPage({
    super.key,
    required this.controller,
    required this.searchController,
    required this.searchFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: EdgeInsets.all(16.w), child: _buildHeader(context)),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => controller.refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    _buildSearchSection(context, controller, searchController),
                    SizedBox(height: 10.h),
                    Obx(() {
                      if (controller.walletInfo.value != null) {
                        return Column(
                          children: [
                            _buildWalletInfo(context, controller, searchController),
                            SizedBox(height: 10.h),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    _buildStatsCards(context, controller),
                    SizedBox(height: 24.h),
                    _buildRecentTransactions(context, controller),
                    SizedBox(height: 24.h),
                    _buildLatestBlocks(context, controller),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Stub methods to fix errors. Replace with actual implementations as needed.
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            FontAwesomeIcons.cube,
            color: AppTheme.textPrimary,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TON Blocks',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Explore TON Blockchain',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context, dynamic controller, TextEditingController searchController) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.search,
                color: AppTheme.primaryColor,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Search Wallet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hintText: 'Enter TON wallet address...',
                  controller: searchController,
                  focusNode: searchFocusNode,
                  prefixIcon: Icon(
                    FontAwesomeIcons.wallet,
                    color: AppTheme.textSecondary,
                    size: 16.sp,
                  ),
                  onChanged: (value) {
                    if (controller.errorMessage.value.isNotEmpty) {
                      controller.errorMessage.value = '';
                    }
                  },
                  onSubmitted: (value) async {
                    if (value.trim().isNotEmpty) {
                      final searchText = value.trim();
                      searchFocusNode.unfocus();
                      FocusScope.of(context).unfocus();
                      searchController.clear();
                      await controller.searchWalletFromUI(searchText);
                    }
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Obx(() => Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF725741), Color(0xFF29775D), Color(0xFF6D4679)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: controller.isLoading.value
                        ? null
                        : () async {
                            if (searchController.text.trim().isNotEmpty) {
                              final searchText = searchController.text.trim();
                              searchFocusNode.unfocus();
                              FocusScope.of(context).unfocus();
                              searchController.clear();
                              await controller.searchWalletFromUI(searchText);
                            } else {
                              controller.errorMessage.value = 'Please enter a wallet address';
                            }
                          },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Center(
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Icon(
                              Icons.search,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              )),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  controller.errorMessage.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.errorColor),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildWalletInfo(BuildContext context, dynamic controller, TextEditingController searchController) {
    final wallet = controller.walletInfo.value!;
    return GradientCard(
      colors: [
        AppTheme.successColor.withOpacity(0.1),
        AppTheme.accentColor.withOpacity(0.1),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.wallet,
                color: AppTheme.successColor,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Wallet Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: () {
                  searchFocusNode.unfocus();
                  FocusScope.of(context).unfocus();
                  controller.clearSearch();
                  searchController.clear();
                },
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppTheme.textSecondary,
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Balance',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              Text(
                '${controller.formatAmount(wallet.balance)} TON',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Address: ${_formatAddressWithAsterisks(controller.searchAddress.value)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                ),
              ),
              StatusChip(status: wallet.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, dynamic controller) {
    return Row(
      children: [
        Expanded(child: Obx(() => _buildTonPriceCard(context, controller))),
        SizedBox(width: 12.w),
        Expanded(
          child: Obx(() => _buildStatCard(
            context,
            controller.searchAddress.value.isNotEmpty ? 'Address TXs' : 'Search Address',
            controller.searchAddress.value.isNotEmpty ? '${controller.totalTransactionCount.value}${controller.totalTransactionCount.value >= 100 ? '+' : ''}' : '-',
            FontAwesomeIcons.exchangeAlt,
            AppTheme.secondaryColor,
          )),
        ),
      ],
    );
  }

  Widget _buildTonPriceCard(BuildContext context, dynamic controller) {
    if (controller.isLoadingPrice.value) {
      return _buildPriceLoadingCard();
    }
    return GradientCard(
      colors: [
        AppTheme.accentColor.withOpacity(0.1),
        AppTheme.accentColor.withOpacity(0.05),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('asset/images/ton.png', width: 20.w, height: 20.h),
          SizedBox(height: 12.h),
          Text(
            'TON Price',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          Row(
            children: [
              Text(
                '${controller.tonPrice.value}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: controller.isPricePositive.value ? AppTheme.successColor.withOpacity(0.2) : AppTheme.errorColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${controller.isPricePositive.value ? '+' : '-'}${controller.priceChange.value}%',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: controller.isPricePositive.value ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLoadingCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomShimmer(width: 20.w, height: 20.h),
          SizedBox(height: 12.h),
          CustomShimmer(width: 60.w, height: 14.h),
          SizedBox(height: 8.h),
          CustomShimmer(width: 80.w, height: 16.h),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return GradientCard(
      colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 12.h),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, dynamic controller) {
    return Obx(() {
      if (controller.searchAddress.value.isEmpty) {
        return _buildEmptyState('No transactions found');
      } else if (controller.isLoadingTransactions.value) {
        return _buildTransactionLoadingList();
      } else if (controller.recentTransactions.isEmpty) {
        return _buildEmptyState('No transactions found');
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.history, color: AppTheme.primaryColor, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                ),
                if (controller.recentTransactions.isNotEmpty && controller.searchAddress.value.isNotEmpty)
                  ElevatedButton(
                    onPressed: () => controller.navigateToTransactions(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.textPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text('All Transactions', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            AnimationLimiter(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.recentTransactions.length,
                separatorBuilder: (context, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final transaction = controller.recentTransactions[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildTransactionCard(context, controller, transaction),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
    });
  }

  Widget _buildTransactionCard(BuildContext context, dynamic controller, dynamic transaction) {
    return GradientCard(
      onTap: () => controller.navigateToTransactionDetail(transaction),
      child: Row(
        children: [
          Container(
            width: 35.w,
            height: 35.h,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(FontAwesomeIcons.exchangeAlt, color: AppTheme.primaryColor, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Txn: ${_formatTransactionHash(transaction.hash)}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppTheme.textPrimary, fontFamily: 'Roboto')),
                SizedBox(height: 4.h),
                Text(controller.getTimeAgo(transaction.timestamp), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${controller.formatAmount(transaction.amount)} TON', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              SizedBox(height: 4.h),
              StatusChip(status: transaction.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLatestBlocks(BuildContext context, dynamic controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.cubes, color: AppTheme.primaryColor, size: 16.sp),
            SizedBox(width: 8.w),
            Text('Latest Blocks', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: 16.h),
        Obx(() {
          if (controller.isLoading.value) {
            return _buildBlockLoadingList();
          }
          if (controller.latestBlocks.isEmpty) {
            return _buildEmptyState('No blocks found');
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.latestBlocks.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final block = controller.latestBlocks[index];
              return _buildBlockCard(context, block);
            },
          );
        }),
      ],
    );
  }

  Widget _buildBlockCard(BuildContext context, Map<String, dynamic> block) {
    return GradientCard(
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(FontAwesomeIcons.cube, color: AppTheme.primaryColor, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Block #${block['seqno'] ?? 'N/A'}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                SizedBox(height: 4.h),
                Text('Hash: ${block['root_hash']?.toString().substring(0, 16) ?? 'N/A'}...', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Icon(FontAwesomeIcons.chevronRight, color: AppTheme.textSecondary, size: 12.sp),
        ],
      ),
    );
  }

  Widget _buildTransactionLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              CustomShimmer(width: 40.w, height: 40.h),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmer(width: 200.w, height: 16.h),
                    SizedBox(height: 8.h),
                    CustomShimmer(width: 100.w, height: 12.h),
                  ],
                ),
              ),
              CustomShimmer(width: 60.w, height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlockLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              CustomShimmer(width: 40.w, height: 40.h),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmer(width: 120.w, height: 16.h),
                    SizedBox(height: 8.h),
                    CustomShimmer(width: 180.w, height: 12.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Builder(
      builder: (context) => GradientCard(
        child: Column(
          children: [
            Icon(FontAwesomeIcons.inbox, color: AppTheme.textSecondary, size: 48.sp),
            SizedBox(height: 16.h),
            Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  String _formatAddressWithAsterisks(String address) {
    if (address.length <= 12) {
      return address;
    }
    final beginning = address.substring(0, 9);
    final end = address.substring(address.length - 3);
    return '$beginning****$end';
  }

  String _formatTransactionHash(String hash) {
    if (hash.length <= 11) {
      return hash;
    }
    final beginning = hash.substring(0, 7);
    final end = hash.substring(hash.length - 4);
    return '$beginning...$end';
  }
}
