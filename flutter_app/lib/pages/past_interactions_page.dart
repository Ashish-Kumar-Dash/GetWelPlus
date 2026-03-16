import 'package:flutter/material.dart';
import 'package:flutter_app/models/meeting_model.dart';
import 'package:flutter_app/widgets/meeting_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PastInteractionsPage extends StatefulWidget {
  final String patientId;
  final String patientDisplayId;

  const PastInteractionsPage({
    super.key,
    required this.patientId,
    required this.patientDisplayId,
  });

  @override
  State<PastInteractionsPage> createState() => _PastInteractionsPageState();
}

class _PastInteractionsPageState extends State<PastInteractionsPage> {
  List<Meeting> _meetings = [];
  bool _isLoading = true;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchInteractions();
  }

  Future<void> _fetchInteractions() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('meetings')
          .select('*, patient_profiles(display_id, full_name)')
          .eq('patient_id', widget.patientId)
          .eq('status', 'confirmed')
          .lt('scheduled_at', DateTime.now().toIso8601String())
          .order('scheduled_at', ascending: false);

      setState(() {
        _meetings = (response as List)
            .map((json) => Meeting.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching interactions: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patientDisplayId} — History'),
        centerTitle: true,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            )
          : _meetings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_outlined,
                          size: 52, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No past interactions yet',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _meetings.length,
                  itemBuilder: (context, index) => MeetingCard(
                    meeting: _meetings[index],
                    onTap: () {},
                    onCancel: null,
                    onJoin: null,
                  ),
                ),
    );
  }
}