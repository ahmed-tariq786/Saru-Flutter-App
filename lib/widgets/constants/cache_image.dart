import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CacheImage extends StatefulWidget {
  const CacheImage({
    super.key,
    required this.pic,
    required this.width,
    required this.height,
    this.radius = 50,
    this.fit = BoxFit.fitWidth,
  });

  final double width;
  final double height;
  final String pic;
  final double radius;
  final BoxFit fit;

  @override
  State<CacheImage> createState() => _ImageNetworkState();
}

class _ImageNetworkState extends State<CacheImage> {
  int _reloadCounter = 0;
  bool _isLoaded = false;

  void _reloadImage() {
    setState(() {
      _reloadCounter++;
      _isLoaded = false; // reset loading state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Show shimmer only while loading
        if (!_isLoaded)
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade800,
              highlightColor: Colors.grey.shade500,
              child: Container(
                width: widget.width,
                height: widget.height,
                color: Colors.white12,
              ),
            ),
          ),
        // Cached image on top
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: CachedNetworkImage(
            key: ValueKey(_reloadCounter),
            imageUrl: widget.pic,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 100),
            placeholder: (context, url) => const SizedBox(),
            imageBuilder: (context, imageProvider) {
              // Called when image loads successfully
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_isLoaded) {
                  setState(() {
                    _isLoaded = true;
                  });
                }
              });
              return Image(
                image: imageProvider,
                fit: widget.fit,
                width: widget.width,
                height: widget.height,
              );
            },
            errorWidget: (context, error, stackTrace) {
              final hasUrl = widget.pic.isNotEmpty;
              final errorContent = Container(
                width: widget.width,
                height: widget.height,
                color: const Color.fromARGB(255, 120, 120, 120),
                child: hasUrl
                    ? const Center(
                        child: Icon(Icons.refresh, color: Colors.white70),
                      )
                    : const SizedBox.shrink(),
              );

              if (hasUrl) {
                return GestureDetector(
                  onTap: _reloadImage,
                  child: errorContent,
                );
              } else {
                return errorContent;
              }
            },
          ),
        ),
      ],
    );
  }
}
