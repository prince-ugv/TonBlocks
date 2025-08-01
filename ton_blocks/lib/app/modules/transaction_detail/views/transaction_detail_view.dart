import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../controllers/transaction_detail_controller.dart';

class TransactionDetailView extends GetView<TransactionDetailController> {
  const TransactionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Transaction Details',
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
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.transaction.value == null) {
          return _buildErrorView('No transaction data available');
        }

        if (controller.isLoading.value) {
          return _buildLoadingView();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorView(controller.errorMessage.value);
        }

        final transaction = controller.detailedTransaction.value ?? controller.transaction.value!;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTransactionHeader(transaction),
              SizedBox(height: 20.h),
              _buildTransactionDetails(transaction),
              SizedBox(height: 20.h),
              _buildAddressDetails(transaction),
              if (transaction.comment != null && transaction.comment!.isNotEmpty) ...[
                SizedBox(height: 20.h),
                _buildCommentSection(transaction.comment!),
              ],
              SizedBox(height: 20.h),
              _buildTechnicalDetails(transaction),
            ],
          ),
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
            'Loading transaction details...',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
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
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: controller.refresh,
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

  Widget _buildTransactionHeader(transaction) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 212, 175, 55), // Gold
                      Color.fromARGB(255, 41, 119, 93),  // Green
                      Color.fromARGB(255, 109, 70, 121), // Purple
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 28.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      controller.getFormattedDate(transaction.timestamp),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(status: transaction.status),
            ],
          ),
          SizedBox(height: 16.h),
          Center(
            child: Column(
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${controller.formatAmount(transaction.amount)} TON',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                if (transaction.fee != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'Fee: ${controller.formatAmount(transaction.fee!)} TON',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(transaction) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            'Hash',
            transaction.hash,
            showCopy: true,
            copyValue: transaction.hash,
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            'Time',
            '${controller.getFormattedDate(transaction.timestamp)} (${controller.getTimeAgo(transaction.timestamp)})',
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            'Status',
            transaction.status.toUpperCase(),
          ),
          if (transaction.blockSeqno > 0) ...[
            SizedBox(height: 12.h),
            _buildDetailRow(
              'Block',
              transaction.blockSeqno.toString(),
            ),
          ],
          if (transaction.lt > 0) ...[
            SizedBox(height: 12.h),
            _buildDetailRow(
              'Logical Time',
              transaction.lt.toString(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressDetails(transaction) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildAddressRow(
            'From',
            transaction.from,
            Icons.arrow_upward,
            AppTheme.errorColor,
          ),
          SizedBox(height: 16.h),
          _buildAddressRow(
            'To',
            transaction.to,
            Icons.arrow_downward,
            AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String address, IconData icon, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 16.w,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => controller.copyToClipboard(address),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textPrimary,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.copy,
                  size: 16.w,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentSection(String comment) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comment/Message',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              comment,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetails(transaction) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            'Transaction Hash',
            controller.formatAddress(transaction.hash),
            showCopy: true,
            copyValue: transaction.hash,
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            'Amount (nanotons)',
            transaction.amount,
          ),
          if (transaction.fee != null) ...[
            SizedBox(height: 12.h),
            _buildDetailRow(
              'Fee (nanotons)',
              transaction.fee!,
            ),
          ],
          SizedBox(height: 12.h),
          _buildDetailRow(
            'Timestamp',
            transaction.timestamp.millisecondsSinceEpoch.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool showCopy = false, String? copyValue}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (showCopy) ...[
                SizedBox(width: 8.w),
                InkWell(
                  onTap: () => controller.copyToClipboard(copyValue ?? value),
                  child: Icon(
                    Icons.copy,
                    size: 16.w,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
