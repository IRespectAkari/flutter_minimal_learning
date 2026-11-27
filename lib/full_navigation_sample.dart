import 'package:flutter/material.dart';

class FullNavigationSample extends StatefulWidget {
  const FullNavigationSample({super.key});

  @override
  State<FullNavigationSample> createState() => _FullNavigationSampleState();
}

class _FullNavigationSampleState extends State<FullNavigationSample> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isAnimatingByTap = false; // タップ移動中のチラつき防止フラグ

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // BottomNavigationBarタップ時の処理
  Future<void> _onBottomNavTapped(int index) async {
    setState(() {
      _currentIndex = index;
      _isAnimatingByTap = true;
    });

    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    _isAnimatingByTap = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 左右のドロワーを設定
      drawer: const Drawer(child: Center(child: Text('左ドロワー'))),
      endDrawer: const Drawer(child: Center(child: Text('右ドロワー'))),

      // 画面端からスワイプでドロワーが開く幅（論理ピクセル）
      // 35.0 〜 50.0 程度でスマホの約0.5〜1cmに相当します
      drawerEdgeDragWidth: 40.0,

      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          // 下部バーのタップアニメーション中は更新をスキップ（チラつき防止）
          if (!_isAnimatingByTap) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        children: [
          _buildSimplePage('ページA', Colors.blue.shade50),
          _buildSimplePage('ページB', Colors.green.shade50),
          _buildPageCWithTabs(_pageController), // タブを持つページC
        ],
      ),

      // 下部のナビゲーションバー
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ページA'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'ページB'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'ページC'),
        ],
      ),
    );
  }

  // 通常のページ（A, B）
  Widget _buildSimplePage(String title, Color bgColor) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        color: bgColor,
        child: Center(child: Text(title, style: const TextStyle(fontSize: 24))),
      ),
    );
  }

  // 内部にTabBarViewを持つページC
  Widget _buildPageCWithTabs(PageController mainpageController) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ページC'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'タブA'),
              Tab(text: 'タブB'),
              Tab(text: 'タブC'),
            ],
          ),
        ),
        body: NotificationListener<OverscrollNotification>(
          onNotification: (notification) {
            // タブA表示中にさらに右へスワイプ（左方向への移動要求）されたらページBへ
            if (notification.overscroll < 0) {
              mainpageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
              return true;
            }
            return false;
          },
          child: const TabBarView(
            physics: ClampingScrollPhysics(),
            children: [
              Center(child: Text('タブAの内容（右スワイプでページBへ）')),
              Center(child: Text('タブBの内容')),
              Center(child: Text('タブCの内容（右端スワイプで右ドロワーが開く）')),
            ],
          ),
        ),
      ),
    );
  }
}
