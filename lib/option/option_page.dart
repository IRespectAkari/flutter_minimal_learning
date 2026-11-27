import 'package:flutter/material.dart';

class OptionPage extends StatelessWidget {
  const OptionPage({
    super.key,
    required this.onResetDatabase,
    required this.onLoadInitialData,
  });

  final Future<void> Function() onResetDatabase;
  final Future<bool> Function() onLoadInitialData;


  // SnackBar表示
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  // DBリセット確認
  Future<void> _resetDatabase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データベースのリセット'),
        content: const Text(
          'すべてのタスクを削除します。\n'
              'この操作は取り消せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'リセット',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await onResetDatabase();

      if (!context.mounted) return;

      _showMessage(context, 'データベースをリセットしました。');
    } catch (e) {
      if (!context.mounted) return;

      _showMessage(context, 'リセットに失敗しました: $e');
    }
  }


  // サンプルデータ読み込み確認
  Future<void> _loadInitialData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('サンプルデータの読み込み'),
        content: const Text(
          'サンプルデータを読み込みます。\n'
              '既存のタスクは削除されません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('読み込む'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final inserted = await onLoadInitialData();

      if (!context.mounted) return;

      _showMessage(
        context,
        inserted
            ? 'サンプルデータを読み込みました。'
            : 'サンプルデータは既に読み込み済みです。',
      );
    } catch (e) {
      if (!context.mounted) return;

      _showMessage(context, '読み込みに失敗しました: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          // データ管理
          Text(
            'データ管理',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [

                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('サンプルデータを読み込む'),
                  subtitle: const Text('サンプルのタスク・予定を登録'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _loadInitialData(context),
                ),

                const Divider(height: 1),

                ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: const Text('データベースをリセット'),
                  subtitle: const Text('すべてのタスクを削除'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _resetDatabase(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 外部連携
          Text(
            '外部連携',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          Card(
            child: Column(
              children: const [

                ListTile(
                  leading: Icon(Icons.calendar_month),
                  title: Text('Google カレンダー'),
                  subtitle: Text('準備中'),
                  enabled: false,
                ),

                Divider(height: 1),

                ListTile(
                  leading: Icon(Icons.file_open),
                  title: Text('カレンダーファイル（.ics）'),
                  subtitle: Text('準備中'),
                  enabled: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

