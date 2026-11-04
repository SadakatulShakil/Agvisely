import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/empty_state_widget.dart';
import '../../domen/controllers/menu_tree_controller.dart';
import '../../domen/custom_code_actions.dart';
import '../widgets/menu_rows.dart';
import '../widgets/custom_code_row.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.isRegistered<MenuTreeController>()
            ? Get.find<MenuTreeController>()
            : Get.put(MenuTreeController(), permanent: true);

    final isBn = Get.locale?.languageCode == 'bn';

    return SafeArea(
      child: Obx(() {
        final node = controller.currentNode.value;

        return PopScope(
          canPop: node == null,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            controller.goBack();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (node == null)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 10.h),
                  child: Text(
                    'menu.title'.tr,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w400,
                      color: FigmaColors.primaryDefault,
                    ),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 20.h, 16.w, 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/svg/arrow_back.svg',
                          width: 30.w,
                          height: 30.h,
                        ),
                        onPressed: controller.goBack,
                      ),
                      Text(
                        node.parentId == null
                            ? 'menu.title'.tr
                            : node.displayTitle(isBn),
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w400,
                          color: FigmaColors.primaryDefault,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child:
                    node == null
                        ? Obx(() => _buildRootBody(controller, isBn))
                        : _MenuList(
                          rows: flattenCustomCodes(node.children, isBn),
                          controller: controller,
                        ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

Widget _buildRootBody(MenuTreeController controller, bool isBn) {
  if (controller.isLoading.value) {
    return const Center(child: CircularProgressIndicator());
  }

  final error = controller.errorMessage.value;
  if (error != null) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 36.sp,
              color: AppColors.textSecondaryLight,
            ),
            SizedBox(height: 12.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: controller.load,
              child: Text('menu.load_failed_retry'.tr),
            ),
          ],
        ),
      ),
    );
  }

  final rows = flattenCustomCodes(controller.items, isBn);
  if (rows.isEmpty) {
    return EmptyStateWidget(message: 'menu.empty'.tr);
  }

  return RefreshIndicator(
    onRefresh: controller.load,
    child: _MenuList(rows: rows, controller: controller, padTop: 0.h),
  );
}

class _MenuList extends StatelessWidget {
  const _MenuList({required this.rows, required this.controller, this.padTop});

  final List<MenuRow> rows;
  final MenuTreeController controller;

  /// Top padding override — the root list sits right below the "Menu"
  /// title with none, while a drill-down level leaves room below its
  /// back-arrow header. Defaults to the latter.
  final double? padTop;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return EmptyStateWidget(message: 'menu.empty'.tr);

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20.w,
        padTop ?? 8.h,
        20.w,
        padTop == null ? 16.h : 10.h,
      ),
      itemCount: rows.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, i) {
        final row = rows[i];
        if (row is MenuRowHeader) {
          return Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 8.h, bottom: 4.h),
            child: Text(
              "",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: FigmaColors.neutralSecondary,
              ),
            ),
          );
        }

        final item = (row as MenuRowItem).node;
        return CustomCodeRow(
          node: item,
          onTap: () => handleCustomCodeTap(item, onOpenList: controller.open),
        );
      },
    );
  }
}
