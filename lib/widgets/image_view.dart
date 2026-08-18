import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

/// Izohli rasm kartochkasi. Bosilganda to'liq ekranda ochiladi (zoom bilan).
class CaptionedImage extends StatelessWidget {
  final String src;
  final String caption;
  final String? badge;
  final double maxHeight;

  const CaptionedImage({
    super.key,
    required this.src,
    required this.caption,
    this.badge,
    this.maxHeight = 260,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showImageViewer(context, src, caption),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  color: const Color(0xFFF1F5F9),
                  child: Image.asset(
                    src,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) => const SizedBox(
                      height: 90,
                      child: Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xCC0F172A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.zoom_in,
                      size: 15, color: Colors.white),
                ),
              ),
              if (badge != null)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xCC0F172A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (caption.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

/// To'liq ekranli rasm ko'ruvchi — barmoq bilan kattalashtirish mumkin.
void showImageViewer(BuildContext context, String src, String caption) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _ImageViewerPage(src: src, caption: caption),
    ),
  );
}

class _ImageViewerPage extends StatelessWidget {
  final String src;
  final String caption;

  const _ImageViewerPage({required this.src, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Rasm'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 6,
              child: Center(
                child: Image.asset(src, fit: BoxFit.contain),
              ),
            ),
          ),
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
              child: Text(
                caption,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13, height: 1.45),
              ),
            ),
        ],
      ),
    );
  }
}

/// Modul rasmlari galereyasi — gorizontal aylanuvchi lenta.
class ModuleGallery extends StatelessWidget {
  final List<ModuleImage> images;
  final String title;

  const ModuleGallery({
    super.key,
    required this.images,
    this.title = 'Rasmlar',
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Row(
            children: [
              const Icon(Icons.photo_library_outlined,
                  size: 17, color: AppColors.primary),
              const SizedBox(width: 7),
              Text(
                '$title (${images.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final im = images[i];
              return SizedBox(
                width: 230,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            showImageViewer(context, im.src, im.caption),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 230,
                                height: double.infinity,
                                color: const Color(0xFFF1F5F9),
                                child: Image.asset(im.src, fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: AppColors.textMuted,
                                          ),
                                        )),
                              ),
                            ),
                            Positioned(
                              left: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xCC0F172A),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  im.roleLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      im.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
