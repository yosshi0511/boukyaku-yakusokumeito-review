import 'package:flutter/material.dart';

void main() {
  runApp(const MemoApp());
}

// アプリ本体
class MemoApp extends StatelessWidget {
  const MemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'やくそくメイト',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MemoListPage(),
    );
  }
}

// メモのデータ
class Memo {
  String title;
  String content;
  DateTime updatedAt;

  Memo({
    required this.title,
    required this.content,
    required this.updatedAt,
  });
}

// メモ一覧画面
class MemoListPage extends StatefulWidget {
  const MemoListPage({super.key});

  @override
  State<MemoListPage> createState() => _MemoListPageState();
}

class _MemoListPageState extends State<MemoListPage> {
  // 作成したメモを保存するリスト
  final List<Memo> memos = [];

  // 新しいメモを作成
  Future<void> createMemo() async {
    final Memo? newMemo = await Navigator.push<Memo>(
      context,
      MaterialPageRoute(
        builder: (context) => const MemoEditPage(),
      ),
    );

    if (newMemo != null) {
      setState(() {
        memos.add(newMemo);
      });
    }
  }

  // メモを編集
  Future<void> editMemo(int index) async {
    final Memo? editedMemo = await Navigator.push<Memo>(
      context,
      MaterialPageRoute(
        builder: (context) => MemoEditPage(
          memo: memos[index],
        ),
      ),
    );

    if (editedMemo != null) {
      setState(() {
        memos[index] = editedMemo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('共有メモ'),
      ),

      body: memos.isEmpty
          ? const Center(
              child: Text(
                'メモがありません\n右下の＋から作成できます',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: memos.length,
              itemBuilder: (context, index) {
                final memo = memos[index];

                return ListTile(
                  leading: const Icon(Icons.note),
                  title: Text(
                    memo.title.isEmpty ? '無題' : memo.title,
                  ),
                  subtitle: Text(
                    memo.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),

                  onTap: () {
                    editMemo(index);
                  },
                );
              },
            ),

      // メモ作成ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: createMemo,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// メモ作成・編集画面
class MemoEditPage extends StatefulWidget {
  final Memo? memo;

  const MemoEditPage({
    super.key,
    this.memo,
  });

  @override
  State<MemoEditPage> createState() => _MemoEditPageState();
}

class _MemoEditPageState extends State<MemoEditPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.memo?.title ?? '',
    );

    contentController = TextEditingController(
      text: widget.memo?.content ?? '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  // 保存
  void saveMemo() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    // タイトルも本文も空なら保存しない
    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('タイトルまたは本文を入力してください'),
        ),
      );
      return;
    }

    final memo = Memo(
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, memo);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.memo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'メモを編集' : 'メモを作成'),

        actions: [
          IconButton(
            onPressed: saveMemo,
            icon: const Icon(Icons.save),
            tooltip: '保存',
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // タイトル
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                hintText: 'メモのタイトル',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // 本文
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,

                decoration: const InputDecoration(
                  labelText: '本文',
                  hintText: 'メモを入力してください',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 保存ボタン
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: saveMemo,
                icon: const Icon(Icons.save),
                label: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}