import 'package:flutter/material.dart';

typedef RadialActionCallback = void Function(BuildContext context);

@immutable
class RadialAction {
  const RadialAction({
    required this.label,
    required this.icon,
    required this.offset,
    required this.onSelected,
  });

  final String label;
  final IconData icon;

  /// FABの中心からの相対座標
  final Offset offset;

  /// このアクションが選択されたときの処理
  final RadialActionCallback onSelected;
}