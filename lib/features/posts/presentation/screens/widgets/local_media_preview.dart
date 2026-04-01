import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LocalMediaPreview extends StatefulWidget {
  final File file;
  final String fileType; // 'image' | 'video'
  final VoidCallback onRemove;
  final bool isUploading;

  const LocalMediaPreview({
    super.key,
    required this.file,
    required this.fileType,
    required this.onRemove,
    required this.isUploading,
  });

  @override
  State<LocalMediaPreview> createState() => _LocalMediaPreviewState();
}

class _LocalMediaPreviewState extends State<LocalMediaPreview> {
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.fileType == 'video') {
      _videoCtrl = VideoPlayerController.file(widget.file)
        ..initialize().then((_) {
          if (mounted) setState(() => _videoReady = true);
        });
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Media ──────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: widget.fileType == 'image'
              ? Image.file(
                  widget.file,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : _videoReady
              ? SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _videoCtrl!.value.isPlaying
                          ? _videoCtrl!.pause()
                          : _videoCtrl!.play();
                    }),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: _videoCtrl!.value.size.width,
                              height: _videoCtrl!.value.size.height,
                              child: VideoPlayer(_videoCtrl!),
                            ),
                          ),
                        ),
                        if (!_videoCtrl!.value.isPlaying) _playIcon(),
                      ],
                    ),
                  ),
                )
              : _loadingBox(),
        ),

        // ── Upload overlay ──────────────────────────────────────
        if (widget.isUploading)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        "Uploading...",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // ── Remove button ───────────────────────────────────────
        if (!widget.isUploading)
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _playIcon() => Container(
    padding: const EdgeInsets.all(10),
    decoration: const BoxDecoration(
      color: Colors.black45,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
  );

  Widget _loadingBox() => Container(
    height: 200,
    width: double.infinity,
    color: Colors.black12,
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );
}
