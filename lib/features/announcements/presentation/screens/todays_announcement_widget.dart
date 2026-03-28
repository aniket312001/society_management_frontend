import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';

/// Drop this widget anywhere on the home screen.
/// It auto-fetches active announcements and shows them
/// in an auto-scrolling carousel. Hidden when there's nothing to show.
class TodayAnnouncementsWidget extends StatelessWidget {
  const TodayAnnouncementsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AnnouncementBloc>()..add(const FetchActiveAnnouncements()),
      child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
        buildWhen: (_, curr) =>
            curr is ActiveAnnouncementsLoading ||
            curr is ActiveAnnouncementsLoaded ||
            curr is ActiveAnnouncementsError,
        builder: (context, state) {
          if (state is ActiveAnnouncementsLoading) {
            return const _LoadingPlaceholder();
          }

          if (state is ActiveAnnouncementsLoaded) {
            if (state.announcements.isEmpty) return const SizedBox.shrink();
            if (state.announcements.length == 1) {
              return _SingleCard(announcement: state.announcements.first);
            }
            return _AnnouncementCarousel(announcements: state.announcements);
          }

          // On error: silently hide (home screen shouldn't break)
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Loading shimmer placeholder ───────────────────────────────────────────────
class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 90,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

// ── Single announcement (no carousel needed) ──────────────────────────────────
class _SingleCard extends StatelessWidget {
  final AnnouncementEntity announcement;
  const _SingleCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _AnnouncementTile(announcement: announcement, showDots: false),
    );
  }
}

// ── Auto-scroll carousel ──────────────────────────────────────────────────────
class _AnnouncementCarousel extends StatefulWidget {
  final List<AnnouncementEntity> announcements;
  const _AnnouncementCarousel({required this.announcements});

  @override
  State<_AnnouncementCarousel> createState() => _AnnouncementCarouselState();
}

class _AnnouncementCarouselState extends State<_AnnouncementCarousel> {
  late final PageController _pageController;
  late Timer _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_current + 1) % widget.announcements.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.announcements.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _AnnouncementTile(
                announcement: widget.announcements[i],
                showDots: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.announcements.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Individual tile inside carousel / single card ─────────────────────────────
class _AnnouncementTile extends StatelessWidget {
  final AnnouncementEntity announcement;
  final bool showDots;

  const _AnnouncementTile({required this.announcement, required this.showDots});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.campaign, color: scheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  announcement.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: scheme.onPrimaryContainer,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.body,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onPrimaryContainer.withOpacity(0.8),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (announcement.createdByName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "— ${announcement.createdByName}",
                    style: TextStyle(
                      fontSize: 10,
                      color: scheme.onPrimaryContainer.withOpacity(0.55),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
