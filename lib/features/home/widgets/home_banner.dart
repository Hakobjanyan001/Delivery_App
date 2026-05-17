import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/banner_model.dart';

class HomeBanner extends StatelessWidget {
  final List<BannerModel> banners;
  final String lang;
  final PageController controller;
  final Function(int) onPageChanged;
  final int infiniteFactor;

  const HomeBanner({
    super.key,
    required this.banners,
    required this.lang,
    required this.controller,
    required this.onPageChanged,
    required this.infiniteFactor,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final bannerHeight = isDesktop ? 464.0 : 232.0;
    final textTop = isDesktop ? 108.0 : 54.0;
    final descTop = isDesktop ? 146.0 : 73.0;

    return SizedBox(
      height: bannerHeight,
      child: PageView.builder(
        controller: controller,
        onPageChanged: onPageChanged,
        itemCount: infiniteFactor,
        itemBuilder: (ctx, i) {
          final banner = banners[i % banners.length];
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
                      banner.title.getLocalized(lang),
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
                      banner.description.getLocalized(lang),
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
  }
}
