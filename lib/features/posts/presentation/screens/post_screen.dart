import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/features/posts/presentation/bloc/posts/post_bloc.dart';
import 'package:society_management_app/features/posts/presentation/bloc/posts/post_event.dart';
import 'package:society_management_app/features/posts/presentation/bloc/posts/post_state.dart';
import 'package:society_management_app/features/posts/presentation/screens/comment_sheet.dart';
import 'package:society_management_app/features/posts/presentation/screens/create_post.dart';

import 'post_card.dart';

class PostScreen extends StatefulWidget {
  final String role;
  final int currentUserId;

  const PostScreen({
    super.key,
    required this.role,
    required this.currentUserId,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PostBloc>().add(const LoadMorePosts());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role == "admin";

    return BlocProvider(
      create: (_) => sl<PostBloc>()..add(const FetchPosts()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Community"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      context.read<PostBloc>().add(const FetchPosts()),
                ),
              ],
            ),

            // FAB to open create post sheet
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => CreatePostSheet.show(
                context,
                postBloc: context.read<PostBloc>(),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text("Post"),
            ),

            body: BlocConsumer<PostBloc, PostState>(
              listenWhen: (_, curr) =>
                  curr is PostPageLoaded && curr.message != null,
              listener: (ctx, state) {
                if (state is PostPageLoaded && state.message != null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(state.message!),
                      backgroundColor: state.isError
                          ? Colors.red
                          : Colors.green,
                    ),
                  );
                }
              },
              buildWhen: (_, curr) =>
                  curr is PostInitial ||
                  curr is PostPageLoading ||
                  curr is PostPageLoaded ||
                  curr is PostPageError,
              builder: (context, state) {
                if (state is PostInitial || state is PostPageLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PostPageError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<PostBloc>().add(const FetchPosts()),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PostPageLoaded) {
                  if (state.posts.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async =>
                          context.read<PostBloc>().add(const FetchPosts()),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 56,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "No posts yet. Start the conversation!",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<PostBloc>().add(const FetchPosts()),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: state.posts.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.posts.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final post = state.posts[index];
                        return PostCard(
                          post: post,
                          currentUserId: widget.currentUserId,
                          isAdmin: isAdmin,
                          onLike: () => context.read<PostBloc>().add(
                            ToggleLike(
                              postId: post.id,
                              currentlyLiked: post.likedByMe,
                            ),
                          ),
                          onComment: () => CommentsSheet.show(
                            context,
                            postId: post.id,
                            currentUserId: widget.currentUserId,
                            isAdmin: isAdmin,
                            postBloc: context.read<PostBloc>(),
                          ),
                          onDelete: () => _confirmDelete(context, post.id),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int postId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("This post will be permanently removed."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<PostBloc>().add(DeletePost(postId));
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
