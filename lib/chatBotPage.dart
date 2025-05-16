import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode(debugLabel: 'TextField');
  bool _loading = false;

  final List<Map<String, dynamic>> _localHistory =
      []; // Diubah jadi list of map

  @override
  void initState() {
    super.initState();
    _initChatModel();
  }

  Future<void> _initChatModel() async {
    try {
      final apiKey = dotenv.env['API_KEY'];
      if (apiKey == null) {
        throw Exception('API_KEY tidak ditemukan di .env');
      }
      _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
      _chat = _model.startChat();
    } catch (e) {
      print('❌ Error saat init chat model: $e');
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 750),
          curve: Curves.easeOutCirc,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = _localHistory;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          "Ask Planty",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF99BC85),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: history.length,
              itemBuilder: (context, idx) {
                final message = history[idx];
                return MessageWidget(
                  text: message['text'] ?? '',
                  isFromUser: message['role'] == 'user',
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _textFieldFocus,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Ask everything about plant...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _sendChatMessage,
                  ),
                ),
                const SizedBox(width: 10),
                _loading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                    : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _sendChatMessage(_textController.text),
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _localHistory.add({
        'role': 'user',
        'text': message,
      }); // Tambahkan pesan user
      _loading = true;
    });

    _textController.clear();
    _textFieldFocus.requestFocus();
    _scrollDown();

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;

      if (text == null) {
        _showError('Respon kosong.');
        setState(() => _loading = false);
        return;
      }

      setState(() {
        _localHistory.add({
          'role': 'bot',
          'text': text,
        }); // Tambahkan balasan bot
        _loading = false;
      });
      _scrollDown();
    } catch (e) {
      _showError('Terjadi error: $e');
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Terjadi kesalahan'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
  });

  final String text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color:
                  isFromUser
                      ? const Color(0xFFEAEAEA) // Abu-abu untuk User
                      : const Color(0xFFE8F5E9), // Hijau muda untuk Bot
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
            child: MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
