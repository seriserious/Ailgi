import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

void main() {
  runApp(const AilgiApp());
}

class AilgiApp extends StatelessWidget {
  const AilgiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ailgi',
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/': (context) => const CalendarPage(),
        '/chat': (context) => const ChatPage(),
      },
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ailgi 달력')),
      body: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: selectedDay,
          );
        },
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');

  void _addMessage(types.TextMessage message) {
    setState(() {
      _messages.insert(0, message);
    });

    // 더미 봇 응답 (사용자가 입력한 걸 그대로 echo)
    final bot = const types.User(id: 'bot');
    final reply = types.TextMessage(
      author: bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: "AI 응답: ${message.text}",
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.insert(0, reply);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = ModalRoute.of(context)!.settings.arguments as DateTime?;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedDay != null
              ? "${selectedDay.year}-${selectedDay.month}-${selectedDay.day}"
              : "채팅",
        ),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: (partialText) {
          final textMessage = types.TextMessage(
            author: _user,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: partialText.text,
          );
          _addMessage(textMessage);
        },
        user: _user,
      ),
    );
  }
}
