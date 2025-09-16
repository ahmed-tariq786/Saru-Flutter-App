import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:saru/widgets/constants/cache_image.dart';
import 'package:saru/widgets/constants/colors.dart';

class FullScreenImageViewer extends StatefulWidget {
  final int initialIndex;
  final List<String> images;

  const FullScreenImageViewer({
    super.key,
    required this.initialIndex,
    required this.images,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        margin: EdgeInsets.all(20),
        foregroundDecoration: BoxDecoration(
          color: AppColors.prForeground,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        child: Stack(
          children: [
            // Image PageView
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index % widget.images.length;
                });
              },
              physics: widget.images.length > 1 ? null : NeverScrollableScrollPhysics(),

              itemBuilder: (context, index) {
                final imageIndex = index % widget.images.length;
                final imageUrl = widget.images[imageIndex];
                return InteractiveViewer(
                  child: Center(
                    child: CacheImage(
                      pic: imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      radius: 0,
                    ),
                  ),
                );
              },
            ),

            // Close button
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Page indicator (only if multiple images)
            if (widget.images.length > 1)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: DotsIndicator(
                      dotsCount: widget.images.length,
                      position: _currentPage.toDouble(),
                      decorator: DotsDecorator(
                        size: const Size.square(6.0),
                        activeSize: const Size(14.0, 6.0),
                        spacing: const EdgeInsets.all(3),

                        activeShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),

                        activeColor: AppColors.black,
                        color: AppColors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
