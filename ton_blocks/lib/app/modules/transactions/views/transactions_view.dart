import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../controllers/transactions_controller.dart';

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: controller.refreshTransactions,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return _buildLoadingView();
        }

        if (controller.errorMessage.value.isNotEmpty && controller.transactions.isEmpty) {
          return _buildErrorView();
        }

        return Column(
          children: [
            _buildWalletInfo(),
            Expanded(
              child: _buildTransactionsList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          SizedBox(height: 16.h),
          Text(
            'Loading transactions...',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: AppTheme.errorColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: controller.refreshTransactions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                'Retry',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletInfo() {
    return Obx(() {
      final walletInfo = controller.walletInfo.value;
      if (walletInfo == null) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.all(16.w),
        child: GradientCard(
          colors: [
            Color.fromARGB(255, 143, 57, 35), // blue
            Color(0xFFb721ff), // purple
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.primaryColor,
                    size: 24.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Wallet Info',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildInfoRow('Address', controller.formatAddress(controller.address.value)),
              SizedBox(height: 8.h),
              _buildInfoRow('Balance', '${controller.formatAmount(walletInfo.balance)} TON'),
              SizedBox(height: 8.h),
              _buildInfoRow('Status', walletInfo.status.toUpperCase()),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    return Obx(() {
      
      if (controller.transactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long,
                size: 64.w,
                color: AppTheme.textSecondary,
              ),
              SizedBox(height: 16.h),
              Text(
                'No Transactions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                controller.errorMessage.value.isNotEmpty 
                    ? controller.errorMessage.value 
                    : 'No transactions found for this address',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshTransactions,
        color: AppTheme.primaryColor,
        child: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.transactions.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.transactions.length) {
              // Load more indicator
              return Obx(() => controller.isLoadingMore.value
                  ? Container(
                      padding: EdgeInsets.all(16.h),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: controller.loadMoreTransactions,
                      child: Container(
                        padding: EdgeInsets.all(16.h),
                        child: Center(
                          child: Text(
                            'Load More',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ));
            }

            final transaction = controller.transactions[index];
            return _buildTransactionCard(transaction);
          },
        ),
      );
    });
  }

  Widget _buildTransactionCard(transaction) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: GradientCard(
        onTap: () => controller.navigateToTransactionDetail(transaction),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.swap_horiz,
                    color: AppTheme.primaryColor,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        controller.getTimeAgo(transaction.timestamp),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: transaction.status),
              ],
            ),
            SizedBox(height: 12.h),
            _buildTransactionInfoRow('From', controller.formatAddress(transaction.from)),
            SizedBox(height: 4.h),
            _buildTransactionInfoRow('To', controller.formatAddress(transaction.to)),
            SizedBox(height: 4.h),
            _buildTransactionInfoRow('Amount', '${controller.formatAmount(transaction.amount)} TON'),
            if (transaction.comment != null && transaction.comment!.isNotEmpty) ...[
              SizedBox(height: 4.h),
              _buildTransactionInfoRow('Comment', transaction.comment!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
