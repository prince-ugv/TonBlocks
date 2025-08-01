import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/common_widgets.dart';
import 'package:get/get.dart';
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.image, color: AppTheme.primaryColor, size: 32.w),
        SizedBox(width: 12.w),
        Text(
          'NFT Checker',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

class NftCheckerPage extends StatelessWidget {
  final dynamic controller;
  const NftCheckerPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: _buildHeader(context),
        ),
        Expanded(
          child: Obx(() {
            if (controller.searchAddress.value.isEmpty) {
              return Center(
                child: Text(
                  'Search with a wallet address first!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            }
            if (controller.isLoadingNfts.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              );
            }
            if (controller.nftItems.isNotEmpty) {
              final filteredNfts = controller.nftItems.where((nft) {
                String? imageUrl =
                    nft['preview'] != null && nft['preview']['url'] != null
                        ? nft['preview']['url']
                        : (nft['metadata'] != null && nft['metadata']['image'] != null
                            ? nft['metadata']['image']
                            : null);
                String? nftName =
                    nft['metadata'] != null && nft['metadata']['name'] != null
                        ? nft['metadata']['name']
                        : nft['name'];
                return imageUrl != null && imageUrl.isNotEmpty && nftName != null && nftName.isNotEmpty;
              }).toList();
              if (filteredNfts.isEmpty) {
                return Center(
                  child: Text(
                    'No NFTs with image and name found.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, top: 16.h, bottom: 8.h),
                    child: Text(
                      'NFT Collections Of The Address :',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                      itemCount: filteredNfts.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final nft = filteredNfts[index];
                        String imageUrl =
                            nft['preview'] != null && nft['preview']['url'] != null
                                ? nft['preview']['url']
                                : nft['metadata']['image'];
                        String nftName =
                            nft['metadata'] != null && nft['metadata']['name'] != null
                                ? nft['metadata']['name']
                                : nft['name'];
                        return GradientCard(
                          child: ListTile(
                            leading: Image.network(
                              imageUrl,
                              width: 48.w,
                              height: 48.w,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              nftName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(nft['address'] ?? ''),
                            onTap: () {
                              // Optionally show NFT details
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return Center(
              child: Text(
                'No NFTs found for this address.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}