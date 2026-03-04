import 'package:flutter/material.dart';
import 'package:flutter_app/models/meeting_model.dart';
import 'package:flutter_app/widgets/meeting_card.dart';

class OnlineMeetPage extends StatefulWidget {
  const OnlineMeetPage({super.key});

  @override
  State<OnlineMeetPage> createState() => _OnlineMeetPageState();
}

class _OnlineMeetPageState extends State<OnlineMeetPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final List<Meeting> _allMeetings = [
    Meeting(
      title: 'Session with Dr. Mehta',
      scheduledAt: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'Follow-up on anxiety management',
    ),
    Meeting(
      title: 'Group Therapy',
      scheduledAt: DateTime.now().subtract(const Duration(days: 10)),
      notes: 'Weekly group session',
    ),
    Meeting(
      title: 'Session with Dr. Rao',
      scheduledAt: DateTime.now().add(const Duration(days: 2)),
      notes: 'First consultation',
    ),
    Meeting(
      title: 'Stress Management Workshop',
      scheduledAt: DateTime.now().add(const Duration(days: 7)),
      notes: 'Bring journal',
    ),
  ];

List<Meeting> get _scheduled => _allMeetings.where((m) => !m.isAttended).toList();
List<Meeting> get _attended => _allMeetings.where((m) => m.isAttended).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose(); // always dispose to free memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Meet'),
        centerTitle: true,
        elevation: 4,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4CAF50),
          indicatorWeight: 3,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Scheduled'),
            Tab(text: 'Attended'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Scheduled tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _scheduled.length,
            itemBuilder: (context, index) => MeetingCard(
              meeting: _scheduled[index],
              onTap: () {},
            ),
          ),
          // Attended tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _attended.length,
            itemBuilder: (context, index) => MeetingCard(
              meeting: _attended[index],
              onTap: () {},
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.black,
        onPressed: () {
          // we'll add the bottom sheet here next
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}