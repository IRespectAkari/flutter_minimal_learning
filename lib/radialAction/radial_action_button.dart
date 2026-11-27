
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_minimal_learning/radialAction/radial_action.dart';

class RadialActionButton extends StatefulWidget {
  const RadialActionButton({
    super.key,
    required this.actions,
    this.onTap,
    this.openMenuOnTap = false,
    this.tooltip = 'クイックアクション',
    this.actionButtonSize = 64,
    this.selectionRadius = 42,
  });

  /// 展開するアクション
  final List<RadialAction> actions;

  // 通常タップ時の処理
  final RadialActionCallback? onTap;

  // タップでラジアルメニューが開くか
  final bool openMenuOnTap;

  final String tooltip;

  /// 展開するボタンの直径
  final double actionButtonSize;

  /// 選択判定を行う半径
  final double selectionRadius;

  @override
  State<RadialActionButton> createState() => _RadialActionButtonState();
}

class _RadialActionButtonState extends State<RadialActionButton> {
  // FABの位置を取得するためのKey
  final GlobalKey _fabKey = GlobalKey();

  // Overlay関連
  OverlayEntry? _overlayEntry;
  RenderBox? _overlayBox;

  // 各アクションの画面上の中心座標
  List<Offset> _actionCenters = [];

  // 現在選択されているアクションのインデックス
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(gestures: {
      LongPressGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
          // 長押し判定時間
          () => LongPressGestureRecognizer(duration: const Duration(milliseconds: 300)),

          // コールバックの設定
          (instance) {
            instance
              ..onLongPressStart = _handleLongPressStart
              ..onLongPressMoveUpdate = _handleLongPressMoveUpdate
              ..onLongPressEnd = _handleLongPressEnd
              ..onLongPressCancel = _handleLongPressCancel;
          },
        ),
    },


      child: FloatingActionButton(
        key: _fabKey,
        // tooltip: widget.tooltip,
        // 通常のタップ時のコールバック
        onPressed: () {
          if(widget.openMenuOnTap){
            _showMenu();
          }else {
            widget.onTap?.call(context);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // アクセシビリティ用のラベル(tooltip)を残したい場合は、外側に次のように指定できます。
  // Semantics(
  //   label: widget.tooltip,
  //   button: true,
  //   child: GestureDetector(
  //     // 既存のジェスチャー処理
  //   ),
  // )

  // -----------------------------------------------
  // ジェスチャー処理
  // -----------------------------------------------

  void _handleLongPressStart(LongPressStartDetails details) {
    _showMenu();
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details,) {
    _updateSelection(details.globalPosition);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    // 指を離した最終位置も判定する
    _updateSelection(details.globalPosition);

    final index = _selectedIndex;

    final selectedAction = (index != null && index < widget.actions.length)
        ? widget.actions[index]
        : null;

    // 先にメニューを閉じる
    _closeMenu();

    // 選択されていれば実行
    if (selectedAction != null && mounted) {
      selectedAction.onSelected(context);
    }
  }

  void _handleLongPressCancel() {
    _closeMenu();
  }

  // -----------------------------------------------
  // メニューの表示
  // -----------------------------------------------

  void _showMenu() {
    if (_overlayEntry != null || widget.actions.isEmpty) {
      return;
    }

    final fabContext = _fabKey.currentContext;

    if (fabContext == null) return;

    // 画面全体のOverlayを取得
    final overlay = Overlay.of(context, rootOverlay: true);

    final overlayObject = overlay.context.findRenderObject();
    final fabObject = fabContext.findRenderObject();

    if (overlayObject is! RenderBox || fabObject is! RenderBox) {
      return;
    }

    final overlayBox = overlayObject;
    final fabBox = fabObject;

    // FABの中心座標を取得（グローバル座標）
    final fabCenterGlobal = fabBox.localToGlobal(fabBox.size.center(Offset.zero));

    // Overlay内のローカル座標へ変換
    final anchor = overlayBox.globalToLocal(fabCenterGlobal);

    _overlayBox = overlayBox;

    final halfSize = widget.actionButtonSize / 2;
    const edgePadding = 8.0;

    // 各アクションの表示位置を決定
    _actionCenters = widget.actions.map((action) {
      final raw = anchor + action.offset;

      return Offset(
        _clampPosition(
          raw.dx,
          overlayBox.size.width,
          halfSize,
          edgePadding,
        ),
        _clampPosition(
          raw.dy,
          overlayBox.size.height,
          halfSize,
          edgePadding,
        ),
      );
    }).toList(growable: false);

    _selectedIndex = null;

    // OverlayEntryを作成して表示
    _overlayEntry = OverlayEntry(builder: _buildOverlay,);

    overlay.insert(_overlayEntry!);
  }

  double _clampPosition(
    double value,
    double extent,
    double halfSize,
    double padding,
  ) {
    final min = halfSize + padding;
    final max = extent - halfSize - padding;

    if (max < min) return extent / 2;

    return value.clamp(min, max).toDouble();
  }

  // -----------------------------------------------
  // アクションの選択判定
  // -----------------------------------------------

  void _updateSelection(Offset globalPosition) {
    final overlayBox = _overlayBox;

    if (overlayBox == null) return;

    // 指の位置をOverlay内の座標に変換
    final pointerPosition =
    overlayBox.globalToLocal(globalPosition);

    int? nextIndex;
    var nearestDistance = widget.selectionRadius;

    // 指に最も近いアクションを探す
    for (var i = 0; i < _actionCenters.length; i++) {
      final distance = (pointerPosition - _actionCenters[i]).distance;

      if (distance <= nearestDistance) {
        nearestDistance = distance;
        nextIndex = i;
      }
    }

    // 選択対象が変わった場合だけ再描画
    if (nextIndex != _selectedIndex) {
      _selectedIndex = nextIndex;
      _overlayEntry?.markNeedsBuild();
    }
  }

  // -----------------------------------------------
  // Overlayの描画
  // -----------------------------------------------

  Widget _buildOverlay(BuildContext overlayContext) {
    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < widget.actions.length; i++)
              Positioned(
                left: _actionCenters[i].dx - widget.actionButtonSize / 2,
                top:  _actionCenters[i].dy - widget.actionButtonSize / 2,
                child: _buildActionItem(overlayContext, i),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, int index) {
    final action = widget.actions[index];
    final isSelected = index == _selectedIndex;

    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = isSelected ? colorScheme.primary : colorScheme.surface;
    final foregroundColor = isSelected ? colorScheme.onPrimary : colorScheme.onSurface;

    return GestureDetector(
      onTap: () {
        _closeMenu();
        action.onSelected(context);
      },

      child: AnimatedScale(
        scale: isSelected ? 1.12 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: backgroundColor,
          elevation: isSelected ? 10 : 6,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: widget.actionButtonSize,
            height: widget.actionButtonSize,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action.icon,
                  color: foregroundColor,
                  size: 21,
                ),

                const SizedBox(height: 2),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 10,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------
  // メニューを閉じる
  // -----------------------------------------------

  void _closeMenu() {
    final entry = _overlayEntry;

    _overlayEntry = null;
    _overlayBox = null;
    _actionCenters = [];
    _selectedIndex = null;

    if (entry != null) {
      entry.remove();
      entry.dispose();
    }
  }

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }
}
