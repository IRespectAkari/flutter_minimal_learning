import 'package:flutter/material.dart';

class OptionPage extends StatelessWidget {
  const OptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("設定"),),
      
      body: Center(
        child: Column(
          children: [
            // ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("←戻る")),
            Text("いろいろなおぷしょん"),
            Text("おぷしょん１"),
            Text("おぷしょん２"),
            Text("おぷしょん３"),
            Text("おぷしょん４"),
            Text("おぷしょん５"),
          ],
      )
      )
    );
  }
}
