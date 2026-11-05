import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network image that's cached to disk (via [CachedNetworkImage]) so repeat
/// loads — including across app restarts — are instant, and fades in once
/// loaded instead of popping in abruptly. Shows [placeholder] immediately and
/// while loading in the background (not just after an error, which was the
/// old behavior everywhere this replaces).
///
/// Pass a [key] that changes (e.g. incorporating a reconnect epoch) to force
/// a clean retry.
class FadeNetworkImage extends StatelessWidget {
  const FadeNetworkImage({
    super.key,
    required this.url,
    required this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fadeDuration = const Duration(milliseconds: 350),
  });

  /// Null or empty shows [placeholder] permanently — no request is made.
  final String? url;

  /// Shown immediately, while loading, and (absent [errorWidget]) on error.
  final Widget placeholder;

  /// Shown instead of [placeholder] if the image fails to load. Defaults to
  /// [placeholder] when omitted.
  final Widget? errorWidget;

  final double? width;
  final double? height;
  final BoxFit fit;
  final Duration fadeDuration;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) {
      return SizedBox(width: width, height: height, child: placeholder);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeDuration,
      placeholder:
          (context, url) =>
              SizedBox(width: width, height: height, child: placeholder),
      errorWidget:
          (context, url, error) => SizedBox(
            width: width,
            height: height,
            child: errorWidget ?? placeholder,
          ),
    );
  }
}
