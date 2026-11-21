
import 'package:flutter/material.dart';

class TagSearchHeader extends StatefulWidget {
  final List<String> tags;
  final String? selectedTag;
  final ValueChanged<String?> onTagSelected;
  final ValueChanged<String> onSearchChanged;

  const TagSearchHeader({
    super.key,
    required this.tags,
    required this.selectedTag,
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
      children: [
        // 検索入力欄
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isSearching
              ? _searchField()
              : const SizedBox.shrink(),
        ),

        // タグ一覧
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTag('すべて', ""),
                    ...widget.tags.map((tag) => _buildTag(tag, tag)),
                  ],
                ),
              ),
            ),

            // 通常時のみ検索ボタンを表示
            if (!_isSearching)
              IconButton(
                onPressed: _openSearch,
                icon: const Icon(Icons.search),
              ),
          ],
        ),
      ],
    );
  }

  Padding _searchField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
      ),
    );
  }

  Widget _buildTag(String label, String? value) {
    final selected = widget.selectedTag == value;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => widget.onTagSelected(value),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
