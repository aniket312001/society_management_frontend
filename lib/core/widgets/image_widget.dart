// ── Cached image widget ───────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppImageWidget extends StatelessWidget {
  final String url;
  const AppImageWidget({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: 200,
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 100,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
