import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class ImageIconView extends StatelessWidget {
  const ImageIconView({
    super.key,
    this.assetPath,
    this.scale,
    this.iconColor,
    this.width,
    this.height,
    this.networkPath,
    this.fallbackImage,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
    this.showPlaceHolder = true,
    this.isFitContain,
    this.packageName,
    this.imageFile,
    this.repeat = true,
    this.animate = true,
    this.errorWidget,
    this.placeholderWidget,
    this.backgroundColor,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.fadeInDuration,
    this.fadeOutDuration,
    this.memCacheWidth,
    this.memCacheHeight,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
  });

  final String? assetPath;
  final String? networkPath;
  final String? fallbackImage;
  final double? scale;
  final double? height;
  final double? width;
  final Color? iconColor;
  final BoxFit fit;
  final double borderRadius;
  final bool showPlaceHolder;
  final BoxFit? isFitContain;
  final String? packageName;
  final File? imageFile;

  // Lottie specific properties
  final bool repeat;
  final bool animate;

  // Additional properties
  final Widget? errorWidget;
  final Widget? placeholderWidget;
  final Color? backgroundColor;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final Duration? fadeInDuration;
  final Duration? fadeOutDuration;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final bool isAntiAlias;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (imageFile != null) {
      return _buildFile();
    } else if (assetPath != null && assetPath!.isNotEmpty) {
      return _buildAsset();
    } else if (networkPath != null && networkPath!.isNotEmpty) {
      return _buildNetwork();
    }
    return _buildEmpty();
  }

  Widget _buildFile() {
    final filePath = imageFile!.path.toLowerCase();

    if (_isLottie(filePath)) {
      return _buildLottieFile();
    } else if (_isSvg(filePath)) {
      return _buildSvgFile();
    } else {
      return _buildImageFile();
    }
  }

  Widget _buildAsset() {
    final assetPathLower = assetPath!.toLowerCase();

    if (_isLottie(assetPathLower)) {
      return _buildLottieAsset();
    } else if (_isSvg(assetPathLower)) {
      return _buildSvgAsset();
    } else {
      return _buildImageAsset();
    }
  }

  Widget _buildNetwork() {
    final networkPathLower = networkPath!.toLowerCase();

    if (_isLottie(networkPathLower)) {
      return _buildLottieNetwork();
    } else if (_isSvg(networkPathLower)) {
      return _buildSvgNetwork();
    } else {
      return _buildImageNetwork();
    }
  }

  // Image Asset
  Widget _buildImageAsset() {
    return Image.asset(
      assetPath!,
      height: height,
      width: width,
      fit: fit,
      scale: scale ?? 1.0,
      color: iconColor,
      package: packageName,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
      cacheWidth: memCacheWidth,
      cacheHeight: memCacheHeight,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  // SVG Asset
  Widget _buildSvgAsset() {
    return SvgPicture.asset(
      assetPath!,
      height: height,
      width: width,
      fit: fit,
      colorFilter: iconColor != null
          ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
          : null,
      package: packageName,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      placeholderBuilder: showPlaceHolder
          ? (context) => _buildPlaceholder()
          : null,
    );
  }

  // Lottie Asset
  Widget _buildLottieAsset() {
    return Lottie.asset(
      assetPath!,
      height: height,
      width: width,
      fit: fit,
      repeat: repeat,
      animate: animate,
      package: packageName,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
      frameBuilder: (context, child, composition) {
        if (composition == null && showPlaceHolder) {
          return _buildPlaceholder();
        }
        return child;
      },
      options: LottieOptions(enableMergePaths: true),
    );
  }

  // Image Network
  Widget _buildImageNetwork() {
    return CachedNetworkImage(
      imageUrl: networkPath!,
      color: iconColor,
      height: height,
      width: width,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 500),
      fadeOutDuration: fadeOutDuration ?? const Duration(milliseconds: 300),
      filterQuality: filterQuality,
      errorWidget: (context, url, error) => errorWidget ?? _buildFallback(),
      placeholder: (context, url) =>
          placeholderWidget ??
          (showPlaceHolder ? _buildPlaceholder() : const SizedBox.shrink()),
    );
  }

  // SVG Network
  Widget _buildSvgNetwork() {
    return SvgPicture.network(
      networkPath!,
      height: height,
      width: width,
      fit: fit,
      colorFilter: iconColor != null
          ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
          : null,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      placeholderBuilder: showPlaceHolder
          ? (context) => placeholderWidget ?? _buildPlaceholder()
          : null,
    );
  }

  // Lottie Network
  Widget _buildLottieNetwork() {
    return Lottie.network(
      networkPath!,
      height: height,
      width: width,
      fit: fit,
      repeat: repeat,
      animate: animate,
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _buildFallback(),
      frameBuilder: (context, child, composition) {
        if (composition == null && showPlaceHolder) {
          return placeholderWidget ?? _buildPlaceholder();
        }
        return child;
      },
      options: LottieOptions(enableMergePaths: true),
    );
  }

  // Image File
  Widget _buildImageFile() {
    return Image.file(
      imageFile!,
      height: height,
      width: width,
      fit: fit,
      scale: scale ?? 1.0,
      color: iconColor,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
      cacheWidth: memCacheWidth,
      cacheHeight: memCacheHeight,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  // SVG File
  Widget _buildSvgFile() {
    return SvgPicture.file(
      imageFile!,
      height: height,
      width: width,
      fit: fit,
      colorFilter: iconColor != null
          ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
          : null,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      placeholderBuilder: showPlaceHolder
          ? (context) => _buildPlaceholder()
          : null,
    );
  }

  // Lottie File
  Widget _buildLottieFile() {
    return Lottie.file(
      imageFile!,
      height: height,
      width: width,
      fit: fit,
      repeat: repeat,
      animate: animate,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
      frameBuilder: (context, child, composition) {
        if (composition == null && showPlaceHolder) {
          return _buildPlaceholder();
        }
        return child;
      },
      options: LottieOptions(enableMergePaths: true),
    );
  }

  // Fallback widget
  Widget _buildFallback() {
    if (fallbackImage != null && fallbackImage!.isNotEmpty) {
      final fallbackLower = fallbackImage!.toLowerCase();

      if (_isLottie(fallbackLower)) {
        return Lottie.asset(
          fallbackImage!,
          height: height,
          width: width,
          fit: isFitContain ?? fit,
          repeat: repeat,
          animate: animate,
          package: packageName,
        );
      } else if (_isSvg(fallbackLower)) {
        return SvgPicture.asset(
          fallbackImage!,
          height: height,
          width: width,
          fit: isFitContain ?? fit,
          colorFilter: iconColor != null
              ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
              : null,
          package: packageName,
        );
      } else {
        return Image.asset(
          fallbackImage!,
          height: height,
          width: width,
          fit: isFitContain ?? fit,
          scale: scale ?? 1.0,
          color: iconColor,
          package: packageName,
        );
      }
    }
    return _buildErrorPlaceholder();
  }

  // Placeholder widget
  Widget _buildPlaceholder() {
    return placeholderWidget ?? _buildDefaultPlaceholder();
  }

  // Default placeholder
  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: SizedBox(
          width: (width != null ? width! * 0.3 : 24)
              .clamp(16.0, 32.0)
              .toDouble(),
          height: (height != null ? height! * 0.3 : 24)
              .clamp(16.0, 32.0)
              .toDouble(),
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  // Error placeholder
  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: (width != null && height != null ? (width! + height!) / 8 : 24)
              .clamp(16.0, 48.0)
              .toDouble(),
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  // Empty state
  Widget _buildEmpty() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  // Helper methods to check file types
  bool _isSvg(String path) {
    return path.endsWith('.svg');
  }

  bool _isLottie(String path) {
    return path.endsWith('.json') ||
        path.endsWith('.lottie') ||
        path.contains('lottie');
  }
}
