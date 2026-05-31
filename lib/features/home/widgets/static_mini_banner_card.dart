import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/banner_model.dart';

class StaticMiniBannerCard extends StatefulWidget {
  final BannerModel banner;
  final String lang;

  const StaticMiniBannerCard({
    super.key,
    required this.banner,
    required this.lang,
  });

  @override
  State<StaticMiniBannerCard> createState() => _StaticMiniBannerCardState();
}

class _StaticMiniBannerCardState extends State<StaticMiniBannerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasLink = widget.banner.link != null && widget.banner.link!.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: hasLink ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () async {
          if (hasLink) {
            final url = Uri.parse(widget.banner.link!);
            if (await canLaunchUrl(url)) await launchUrl(url);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isHovered ? -4.0 : 0.0, 0.0)
              * Matrix4.diagonal3Values(_isHovered ? 1.015 : 1.0, _isHovered ? 1.015 : 1.0, 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.35 : 0.15),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
            image: widget.banner.image != null
                ? DecorationImage(
                    image: NetworkImage(widget.banner.image!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Dark gradient overlay
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
                // Text info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.banner.title.getLocalized(widget.lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.banner.description.getLocalized(widget.lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
