import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/pinch_pdf_view.dart';

class PdfViewerPage extends StatelessWidget {
  const PdfViewerPage({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 20.h, 16.w, 8.h),
              child: Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/svg/arrow_back.svg',
                      width: 24.w,
                      height: 24.h,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        color: FigmaColors.primaryDefault,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PinchPdfView(
                fetchBytes: () async {
                  final resp = await http.get(Uri.parse(url));
                  if (resp.statusCode != 200) {
                    throw Exception('menu.pdf_load_failed'.tr);
                  }
                  return resp.bodyBytes;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
