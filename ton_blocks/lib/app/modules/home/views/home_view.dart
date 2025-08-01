import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ton_blocks/app/modules/home/views/nft_checker_tab.dart';
import 'package:ton_blocks/app/modules/home/views/wallet_scanner_tab.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/transaction_model.dart';

import 'ton_fees_calculator_tab.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  int _selectedTabIndex = 0;
  late HomeController controller;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.put(HomeController());

    // Set callback for controller to clear search field
    controller.setClearSearchFieldCallback(() {
      searchController.clear();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Dismiss keyboard when app becomes active (e.g., returning from another page)
      searchFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTabIndex,
          children: [
            // Wallet Scanner Tab
            WalletScannerPage(
              controller: controller,
              searchController: searchController,
              searchFocusNode: searchFocusNode,
            ),
            
            // NFT Checker Tab
            NftCheckerPage(
              controller: controller,
            ),
            // Ton Gas Tab
            TonFeePage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_outlined),
            label: 'NFT Checker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_gas_station_outlined),
            label: 'Ton Gas',
          ),
        ],
      ),
    );
  }

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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          icon: Icon(
            Icons.info_outline,
            color: AppTheme.primaryColor,
            size: 24.w,
          ),
          tooltip: 'Developer Info',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: 8.w),
                          Text('Developer Info'),
                        ],
                      ),
                      SizedBox(height: 7.h),
                      Divider(
                        thickness: 1,
                        color: AppTheme.primaryColor.withOpacity(0.2),
                      ),
                    ],
                  ),
                  titlePadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
                  contentPadding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
                  actionsPadding: EdgeInsets.only(right: 8.w, bottom: 8.h),
                  titleTextStyle: Theme.of(context).textTheme.titleLarge,
                  insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name : Md. Ayub Islam Prince',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.h),
                      Text('B.Sc In CSE'),
                      Text('University Of Global Village ( UGV )'),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'prince.cse@ugv.edu.bd',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.copy,
                              size: 18.w,
                              color: AppTheme.primaryColor,
                            ),
                            tooltip: 'Copy Email',
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: 'prince.cse@ugv.edu.bd'),
                              );
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Email address copied!'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchSection(
    BuildContext context,
    HomeController controller,
    TextEditingController searchController,
  ) {
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
                    // Clear error message when user starts typing
                    if (controller.errorMessage.value.isNotEmpty) {
                      controller.errorMessage.value = '';
                    }
                  },
                  onSubmitted: (value) async {
                    if (value.trim().isNotEmpty) {
                      final searchText = value.trim();

                      // Dismiss keyboard
                      searchFocusNode.unfocus();
                      FocusScope.of(context).unfocus();

                      // Clear the search field
                      searchController.clear();

                      // Search
                      await controller.searchWalletFromUI(searchText);
                    }
                  },
                ),
              ),
              SizedBox(width: 12.w),
              // Search Button
              Obx(
                () => Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 114, 87, 65), // Gold
                        Color.fromARGB(255, 41, 119, 93), // Dark goldenrod
                        Color.fromARGB(255, 109, 70, 121), // Dark goldenrod
                      ],
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

                                // Dismiss keyboard first
                                searchFocusNode.unfocus();
                                FocusScope.of(context).unfocus();

                                // Clear the search field
                                searchController.clear();

                                // Perform search
                                await controller.searchWalletFromUI(searchText);
                              } else {
                                controller.errorMessage.value =
                                    'Please enter a wallet address';
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
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
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
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Error message
          Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  controller.errorMessage.value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.errorColor),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildWalletInfo(
    BuildContext context,
    HomeController controller,
    TextEditingController searchController,
  ) {
    return Obx(() {
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Dismiss keyboard first
                    searchFocusNode.unfocus();
                    FocusScope.of(context).unfocus();
                    // Clear search
                    controller.clearSearch();
                    searchController.clear(); // Also clear the text field
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                StatusChip(status: wallet.status),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatsCards(BuildContext context, HomeController controller) {
    return Row(
      children: [
        Expanded(child: Obx(() => _buildTonPriceCard(context, controller))),
        SizedBox(width: 12.w),
        Expanded(
          child: Obx(
            () => _buildStatCard(
              context,
              controller.searchAddress.value.isNotEmpty
                  ? 'Address TXs'
                  : 'Search Address',
              controller.searchAddress.value.isNotEmpty
                  ? '${controller.totalTransactionCount.value}${controller.totalTransactionCount.value >= 100 ? '+' : ''}'
                  : '-',
              FontAwesomeIcons.exchangeAlt,
              AppTheme.secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTonPriceCard(BuildContext context, HomeController controller) {
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          Row(
            children: [
              Text(
                '\$${controller.tonPrice.value}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: controller.isPricePositive.value
                      ? AppTheme.successColor.withOpacity(0.2)
                      : AppTheme.errorColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${controller.isPricePositive.value ? '+' : '-'}${controller.priceChange.value}%',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: controller.isPricePositive.value
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
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

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GradientCard(
      colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 12.h),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
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

  Widget _buildRecentTransactions(
    BuildContext context,
    HomeController controller,
  ) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.history,
                color: AppTheme.primaryColor,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Recent Transactions',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (controller.recentTransactions.isNotEmpty &&
                  controller.searchAddress.value.isNotEmpty)
                ElevatedButton(
                  onPressed: () => controller.navigateToTransactions(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.textPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'All Transactions',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          if (controller.searchAddress.value.isEmpty)
            _buildEmptyState('No transactions found')
          else if (controller.isLoadingTransactions.value)
            _buildTransactionLoadingList()
          else if (controller.recentTransactions.isEmpty)
            _buildEmptyState('No transactions found')
          else
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
                        child: _buildTransactionCard(
                          context,
                          controller,
                          transaction,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }

  Widget _buildTransactionCard(
    BuildContext context,
    HomeController controller,
    Transaction transaction,
  ) {
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
            child: Icon(
              FontAwesomeIcons.exchangeAlt,
              color: AppTheme.primaryColor,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Txn: ${_formatTransactionHash(transaction.hash)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  controller.getTimeAgo(transaction.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${controller.formatAmount(transaction.amount)} TON',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              StatusChip(status: transaction.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLatestBlocks(BuildContext context, HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              FontAwesomeIcons.cubes,
              color: AppTheme.primaryColor,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Latest Blocks',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
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
            child: Icon(
              FontAwesomeIcons.cube,
              color: AppTheme.primaryColor,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Block #${block['seqno'] ?? 'N/A'}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Hash: ${block['root_hash']?.toString().substring(0, 16) ?? 'N/A'}...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            FontAwesomeIcons.chevronRight,
            color: AppTheme.textSecondary,
            size: 12.sp,
          ),
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
            Icon(
              FontAwesomeIcons.inbox,
              color: AppTheme.textSecondary,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAddressWithAsterisks(String address) {
    if (address.length <= 12) {
      return address; // If address is too short, return as is
    }

    // Take first 9 characters and last 3 characters with **** in between
    final beginning = address.substring(0, 9);
    final end = address.substring(address.length - 3);
    return '$beginning****$end';
  }

  String _formatTransactionHash(String hash) {
    if (hash.length <= 11) {
      return hash; // If hash is too short, return as is
    }

    // Take first 7 characters and last 4 characters with ... in between
    final beginning = hash.substring(0, 7);
    final end = hash.substring(hash.length - 4);
    return '$beginning...$end';
  }
}
