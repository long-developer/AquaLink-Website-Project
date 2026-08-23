import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:project_aqualink/app/providers/app_data_provider.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();

    // Gọi hàm sendMessage trong AppDataProvider
    final provider = context.read<AppDataProvider>();
    provider.sendMessage(text);

    // Tự động cuộn xuống cuối danh sách
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appData = context.watch<AppDataProvider>();
    final messages = appData.messages;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isBot = message['isBot'] as bool;
                  return Align(
                    alignment: isBot
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(
                        color: isBot
                            ? theme.colorScheme.surfaceContainerHighest
                            : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: isBot
                          ? MarkdownBody(
                              data: message['text'] as String,
                              shrinkWrap: true,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  height: 1.35,
                                ),
                                h1: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                h2: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                h3: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                listBullet: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            )
                          : Text(
                              message['text'] as String,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
            if (appData.isBotTyping)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ThinkingDots(
                  label: appData.translate('assistant_thinking'),
                  color: theme.colorScheme.primary,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: appData.translate('assistant_hint'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: theme.colorScheme.onPrimary,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThinkingDots extends StatefulWidget {
  final String label;
  final Color color;

  const ThinkingDots({required this.label, required this.color, super.key});

  @override
  State<ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<ThinkingDots>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animations = [
      TweenSequence<double>([
        TweenSequenceItem(tween: Tween<double>(begin: 0, end: 10), weight: 30),
        TweenSequenceItem(tween: Tween<double>(begin: 10, end: 0), weight: 70),
      ]).animate(_controller),
      TweenSequence<double>([
        TweenSequenceItem(tween: Tween<double>(begin: 0, end: 0), weight: 15),
        TweenSequenceItem(tween: Tween<double>(begin: 0, end: 10), weight: 30),
        TweenSequenceItem(tween: Tween<double>(begin: 10, end: 0), weight: 55),
      ]).animate(_controller),
      TweenSequence<double>([
        TweenSequenceItem(tween: Tween<double>(begin: 0, end: 0), weight: 30),
        TweenSequenceItem(tween: Tween<double>(begin: 0, end: 10), weight: 30),
        TweenSequenceItem(tween: Tween<double>(begin: 10, end: 0), weight: 40),
      ]).animate(_controller),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: widget.color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          height: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_animations[index].value),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
