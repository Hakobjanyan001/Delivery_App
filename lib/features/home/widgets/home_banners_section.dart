import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/banner_model.dart';
import 'static_mini_banner_card.dart';

class HomeBannersSection extends StatefulWidget {
  final List<BannerModel> banners;
  final String lang;

  const HomeBannersSection({
    super.key,
    required this.banners,
    required this.lang,
  });

  @override
  State<HomeBannersSection> createState() => _HomeBannersSectionState();
}

class _HomeBannersSectionState extends State<HomeBannersSection> {
  late PageController _bannersController;
  Timer? _bannerTimer;
  static const int _infiniteFactor = 10000;
  int _currentBannerPage = _infiniteFactor ~/ 2;

  @override
  void initState() {
    super.initState();
    _bannersController = PageController(initialPage: _infiniteFactor ~/ 2);
    _currentBannerPage = _infiniteFactor ~/ 2;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBannerTimer();
    });
  }

  @override
  void dispose() {
    _bannersController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (widget.banners.isNotEmpty && _bannersController.hasClients) {
        _bannersController.animateToPage(
          _currentBannerPage + 1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (!isDesktop) {
      // Mobile carousel layout
      final bannerHeight = 232.0;
      final textTop = 54.0;
      final descTop = 73.0;

      return SizedBox(
        height: bannerHeight,
        child: PageView.builder(
          controller: _bannersController,
          onPageChanged: (i) => _currentBannerPage = i,
          itemCount: _infiniteFactor,
          itemBuilder: (ctx, i) {
            final banner = widget.banners[i % widget.banners.length];
            final hasLink = banner.link != null && banner.link!.isNotEmpty;

            return GestureDetector(
              onTap: () async {
                if (hasLink) {
                  final url = Uri.parse(banner.link!);
                  if (await canLaunchUrl(url)) await launchUrl(url);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surface,
                  image: banner.image != null
                      ? DecorationImage(image: NetworkImage(banner.image!), fit: BoxFit.cover)
                      : null,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.65),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: textTop,
                      left: 32,
                      right: 32,
                      child: Text(
                        banner.title.getLocalized(widget.lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Positioned(
                      top: descTop,
                      left: 32,
                      right: 32,
                      child: Text(
                        banner.description.getLocalized(widget.lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      // Desktop / Web side-by-side layout
      final screenWidth = MediaQuery.of(context).size.width;
      final rightWidth = (screenWidth * 0.45).clamp(320.0, 721.0);
      final rowHeight = 572.0;

      final banner1 = widget.banners.length > 1 ? widget.banners[1] : widget.banners[0];
      final banner2 = widget.banners.length > 2 ? widget.banners[2] : widget.banners[0];

      return Container(
        height: rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left side: PageView (scrolling carousel)
            Expanded(
              child: PageView.builder(
                controller: _bannersController,
                onPageChanged: (i) => _currentBannerPage = i,
                itemCount: _infiniteFactor,
                itemBuilder: (ctx, i) {
                  final banner = widget.banners[i % widget.banners.length];
                  final hasLink = banner.link != null && banner.link!.isNotEmpty;

                  return GestureDetector(
                    onTap: () async {
                      if (hasLink) {
                        final url = Uri.parse(banner.link!);
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      }
                    },
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Theme.of(context).colorScheme.surface,
                        image: banner.image != null
                            ? DecorationImage(image: NetworkImage(banner.image!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.65),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 108.0,
                            left: 48,
                            right: 48,
                            child: Text(
                              banner.title.getLocalized(widget.lang),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 146.0,
                            left: 48,
                            right: 48,
                            child: Text(
                              banner.description.getLocalized(widget.lang),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Right side: Two static mini banners
            SizedBox(
              width: rightWidth,
              child: Column(
                children: [
                  Expanded(
                    child: StaticMiniBannerCard(
                      banner: banner1,
                      lang: widget.lang,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StaticMiniBannerCard(
                      banner: banner2,
                      lang: widget.lang,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
