import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post_comment_model.dart';
import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/ui_helpers.dart';

Future<PostModel?> showPostCommentsSheet(
  BuildContext context, {
  required PostModel post,
}) async {
  return showModalBottomSheet<PostModel>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _PostCommentsSheet(post: post),
  );
}

class _PostCommentsSheet extends StatefulWidget {
  final PostModel post;

  const _PostCommentsSheet({required this.post});

  @override
  State<_PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends State<_PostCommentsSheet> {
  final _commentController = TextEditingController();
  late PostModel _post;
  bool _isLoading = true;
  bool _isSending = false;
  List<PostCommentModel> _comments = [];

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final comments =
          await context.read<PostProvider>().fetchComments(_post.id);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorSnackBar(context, e.message);
    }
  }

  Future<void> _sendComment() async {
    final user = AuthService().currentUser;
    if (user == null) {
      showErrorSnackBar(context, 'Faça login para comentar.');
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final updated = await context.read<PostProvider>().addComment(
            post: _post,
            userId: user.id,
            content: content,
          );
      if (!mounted) return;
      _commentController.clear();
      setState(() => _post = updated);
      await _loadComments();
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(_post);
      },
      child: Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Comentários — ${_post.title}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? const Center(child: Text('Nenhum comentário ainda.'))
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment.userName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(comment.content),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Escreva um comentário...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLength: 500,
                        maxLines: 2,
                        onSubmitted: (_) => _sendComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isSending ? null : _sendComment,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }
}
