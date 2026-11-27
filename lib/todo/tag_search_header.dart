
import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/task/task.dart';

class TagSearchHeader extends StatefulWidget {
  final Set<String> tags;
  final Set<String> selectedTags;
  final TaskStatusFilter selectedState;
  final Map<TaskStatusFilter, int> statusCounts;
  final ValueChanged<String?> onTagSelected;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TaskStatusFilter> onStateSelected;

  const TagSearchHeader({
    super.key,
    required this.tags,
    required this.selectedTags,
    required this.selectedState,
    required this.statusCounts,
    required this.onTagSelected,
    required this.onSearchChanged,
    required this.onStateSelected,
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
      spacing: 4,
      children: [
        // 完了/未完了/全て 選択タブ
        // _buildChoiceCondition(widget.statusCounts),
        _buildChoiceConditionTab(widget.statusCounts/*, widget.selectedState*/),

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
          child: _searchTextField(),
        ),

        TextButton(
          onPressed: _closeSearch,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }

  TextField _searchTextField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'タイトルからタスクを検索',
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _controller.clear();
            widget.onSearchChanged('');
          },
          constraints: const BoxConstraints(),
          iconSize: 20,
          padding: EdgeInsets.all(0),
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: Size.zero,
            padding: const EdgeInsets.all(4),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(
          minHeight: 24,
          minWidth: 24,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        isDense: true,
      ),
    );
  }

  Widget _buildTag(String label, String? value) {
    var tag = (
      color: Color(0xFFF8E8E7),
      label: label,
      value: value,
    );

    // valueが "" または null（「全て」ボタン）なら、選択リストが空のときにtrueにする
    final bool selected = (tag.value == null || tag.value!.isEmpty)
        ? widget.selectedTags.isEmpty
        : widget.selectedTags.contains(tag.value);

    return FilterChip(
      label: Text(tag.label),
      selected: selected,
      onSelected: (_) => widget.onTagSelected(tag.value),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.fromLTRB(1, 4, 1, 4),
      showCheckmark: false, // チェックマークを消す
      backgroundColor: tag.color,
    );
  }


  Widget _buildChoiceConditionTab(Map<TaskStatusFilter, int> statusCounts/*, TaskStatusFilter selectedState*/) {
    // return Row(
    //   spacing: 4.0,
    //   children: TaskStatusFilter.values
    //       .map((filter) => _buildStatusChip(filter, statusCounts))
    //       .map((filter) => Expanded(child: filter))
    //       .toList(),
    // );

    return DefaultTabController(
      length: TaskStatusFilter.values.length, // 3つ（全て・未完了・完了）
      // initialIndex: TaskStatusFilter.values.indexOf(selectedState),
      initialIndex: TaskStatusFilter.values.indexOf(TaskStatusFilter.todo),
      child: TabBar(
        // 画像のように左寄せにしたい場合は isScrollable: true にする
        // 画面幅いっぱいに3等分したい場合は false（デフォルト）にする
        // isScrollable: true,
        isScrollable: false,

        // tabAlignment: TabAlignment.start, // 左寄せ時の余計な左余白を消す（Flutter 3.13以降）

        // デザイン調整（画像のような紫〜紺色の下線と文字色）
        labelColor: const Color(0xFF4A4478),       // 選択中の文字色
        unselectedLabelColor: Colors.grey,         // 非選択の文字色
        indicatorColor: const Color(0xFF4A4478),   // 下線の色
        indicatorWeight: 2.5,                      // 下線の太さ
        // indicatorSize: TabBarIndicatorSize.label,  // 下線の長さを文字幅に合わせる
        indicatorSize: TabBarIndicatorSize.tab,  // 下線の長さをタブの幅に合わせる

        // タブがタップされたときの処理
        onTap: (index) {
          setState(() {
            // selectedState = TaskStatusFilter.values[index];
            widget.onStateSelected(TaskStatusFilter.values[index]);
          });
        },

        // タブの生成（「未完了 (8)」のような表示）
        tabs: TaskStatusFilter.values.map((filter) {
          final count = statusCounts[filter];
          return Tab(
            height: 35,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 13),

                Text(filter.label),

                const SizedBox(width: 4),

                // todo: 4桁を超えたときに改行する仕組みを作る
                SizedBox(
                  width: 36,
                  child: Text(
                    "($count)",
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );

  }

}
