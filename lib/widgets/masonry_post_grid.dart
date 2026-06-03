import 'package:flutter/material.dart';

import '../models/post_model.dart';
import 'post_card.dart';

/// Pinterest-style two-column masonry layout for posts.
class MasonryPostGrid extends StatelessWidget {
  final List<PostModel> posts;
  final void Function(PostModel post)? onTap;
  final void Function(PostModel post)? onLike;
  final void Function(PostModel post)? onComment;

  const MasonryPostGrid({
    super.key,
    required this.posts,
    this.onTap,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final leftColumn = <Widget>[];
    final rightColumn = <Widget>[];

    for (var i = 0; i < posts.length; i++) {
      final post = posts[i];
      final card = PostCard(
        post: post,
        compact: i.isOdd,
        onTap: onTap != null ? () => onTap!(post) : null,
        onLike: onLike != null ? () => onLike!(post) : null,
        onComment: onComment != null ? () => onComment!(post) : null,
      );

      if (i.isEven) {
        leftColumn.add(card);
      } else {
        rightColumn.add(card);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(children: leftColumn)),
        const SizedBox(width: 12),
        Expanded(child: Column(children: rightColumn)),
      ],
    );
  }
}
