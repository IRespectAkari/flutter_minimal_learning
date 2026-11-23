
import 'package:flutter/material.dart';

class TagSearchHeader extends StatefulWidget {
  final List<String> tags;
  final Set<String> selectedTags;
  final ValueChanged<String?> onTagSelected;
  final ValueChanged<String> onSearchChanged;

  const TagSearchHeader({
    super.key,
    required this.tags,
    required this.selectedTags,
    required this.onTagSelected,
    required this.onSearchChanged,
  });

  @override
  State<TagSearchHeader> createState() => _TagSearchHeaderState();
}

class _TagSearchHeaderState extends State<TagSearchHeader> {
  bool _isSearching = false;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  void _openSearch() {
    setState(() {
      _isSearching = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _closeSearch() {
    _controller.clear();
    widget.onSearchChanged('');

    _focusNode.unfocus();

    setState(() {
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        // 完了/未完了/全て 選択タブ
        // _buildChoiceCondition(),

        // 検索入力欄
        _buildSearchField(),

        // タグ一覧
        _buildTagList(),
      ],
    );
  }

  AnimatedSize _buildSearchField() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: _isSearching
          ? _searchField()
          : const SizedBox.shrink(),
    );
  }

  Widget _buildTagList() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 6,
              children: [
                _buildTag('すべて', ""),
                ...widget.tags.map((tag) => _buildTag(tag, tag)),
              ],
            ),
          ),
        ),

        // 通常時のみ検索ボタンを表示
        if (!_isSearching)
          Padding(
            // タグとの間の余白
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton.outlined(
              onPressed: _openSearch,
              // アイコンサイズを少し抑えるとバランスが良い
              icon: const Icon(Icons.search, size: 22),
              // ★ タグリストの高さ（約36px）に合わせる設定
              padding: const EdgeInsets.all(5),
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                // 枠線の色や太さを隣のタグと合わせたい場合はここで微調整
                // side: BorderSide(color: Colors.grey.shade400, width: 1.0),
                side: BorderSide.none,
                backgroundColor: Color(0xFFE6EDFC),
                foregroundColor: Color(0xFF3870B9),
              ),
            ),
          ),

          // InkWell(
          //   onTap: _openSearch,
          //   borderRadius: BorderRadius.circular(20),
          //   child: const Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //     child: Icon(Icons.search),
          //   ),
          // ),

          // IconButton(
          //   onPressed: _openSearch,
          //   icon: const Icon(Icons.search),
          //   // iconSize: 36,
          //   // padding: EdgeInsets.zero,
          //   padding: const EdgeInsets.symmetric(horizontal: 8),
          //   constraints: const BoxConstraints(),
          //   style: IconButton.styleFrom(
          //     tapTargetSize: MaterialTapTargetSize.shrinkWrap
          //   ),
          // ),
      ],);
  }

  Widget _searchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'タスクを検索...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  widget.onSearchChanged('');
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 10),
              isDense: true,
            ),
          ),
        ),

        TextButton(
          onPressed: _closeSearch,
          child: const Text('キャンセル'),
        ),
      ],
    );
  }

  Widget _buildTag(String label, String? value) {
    // valueが "" または null（「全て」ボタン）なら、選択リストが空のときにtrueにする
    final bool selected = (value == null || value.isEmpty)
        ? widget.selectedTags.isEmpty
        : widget.selectedTags.contains(value);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => widget.onTagSelected(value),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.fromLTRB(1, 4, 1, 4),
    );
  }
}
