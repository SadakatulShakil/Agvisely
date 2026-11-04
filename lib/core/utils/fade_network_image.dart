import 'package:flutter/material.dart';

/// Network image that fades in once loaded instead of popping in abruptly,
/// showing [placeholder] immediately and while loading (not just after an
/// error, which was the old behavior everywhere this replaces) — e.g. the
/// generic leaf icon used for crop/item imagery throughout the app.
///
/// Pass a [key] that changes (e.g. incorporating a reconnect epoch) to force
/// a clean retry — changing a StatefulWidget's key discards its State,
/// which resets the error flag along with it.
class FadeNetworkImage extends StatefulWidget {
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
  State<FadeNetworkImage> createState() => _FadeNetworkImageState();
}

class _FadeNetworkImageState extends State<FadeNetworkImage> {
  bool _failed = false;
  // Most of these icons use BoxFit.contain, which leaves transparent padding
  // around the image wherever its aspect ratio doesn't match the box. Only
  // *covering* the placeholder (not fading its opacity to 0 too) left it
  // permanently visible through those gaps even once the image had loaded.
  bool _loaded = false;

  void _markLoaded() {
    if (mounted && !_loaded) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    if (url == null || url.isEmpty || _failed) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child:
            _failed
                ? (widget.errorWidget ?? widget.placeholder)
                : widget.placeholder,
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedOpacity(
            opacity: _loaded ? 0 : 1,
            duration: widget.fadeDuration,
            curve: Curves.easeOut,
            child: widget.placeholder,
          ),
          Image.network(
            url,
            fit: widget.fit,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame != null) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _markLoaded(),
                );
              }
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: widget.fadeDuration,
                curve: Curves.easeOut,
                child: child,
              );
            },
            // Swapping to the dedicated error state via setState (rather than
            // returning it directly here) avoids stacking it on top of
            // [placeholder] — this callback's return value still paints in
            // the same Stack slot as the Image, over the placeholder below.
            errorBuilder: (context, error, stackTrace) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_failed) setState(() => _failed = true);
              });
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
