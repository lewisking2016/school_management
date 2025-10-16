import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
            Tab(icon: Icon(Icons.fingerprint), text: 'My Status'),
            Tab(icon: Icon(Icons.checklist), text: 'Mark Attendance'),
            Tab(
              icon: Icon(Icons.time_to_leave_outlined),
              text: 'Leave Requests',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AttendanceDashboardTab(),
          _MyStatusTab(),
          _MarkAttendanceTab(),
          _LeaveManagementTab(),
        ],
      ),
    );
  }
}

/// Tab 1: Attendance Dashboard with Charts (now Stateful to manage switch states)
class _AttendanceDashboardTab extends StatefulWidget {
  const _AttendanceDashboardTab();

  @override
  State<_AttendanceDashboardTab> createState() =>
      _AttendanceDashboardTabState();
}

class _AttendanceDashboardTabState extends State<_AttendanceDashboardTab> {
  bool _sendAbsenteeismAlerts = true; // Initial state for absenteeism alerts
  bool _sendDailyReminders = false; // Initial state for daily reminders

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Summary',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSummaryCard(
            context,
            title: 'Student Weekly Attendance',
            chart: const _AttendanceChart(
              data: [245, 248, 235, 240, 250],
              total: 250,
              barColor: Colors.orange,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            context,
            title: 'Teacher Weekly Attendance',
            chart: const _AttendanceChart(
              data: [28, 30, 30, 29, 27],
              total: 30,
              barColor: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          _buildNotificationSettings(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required Widget chart,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications & Alerts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Absenteeism Alerts to Parents'),
              subtitle: const Text(
                'Send an automatic alert if a student is absent.',
              ),
              value: _sendAbsenteeismAlerts,
              onChanged: (bool value) {
                setState(() {
                  _sendAbsenteeismAlerts = value;
                });
                // In a real app, you would save this setting to a database or preferences.
              },
              secondary: const Icon(Icons.notifications_active_outlined),
            ),
            SwitchListTile(
              title: const Text('Daily Attendance Reminders'),
              subtitle: const Text('Remind teachers to mark attendance.'),
              value: _sendDailyReminders,
              onChanged: (bool value) {
                setState(() {
                  _sendDailyReminders = value;
                });
                // In a real app, you would save this setting to a database or preferences.
              },
              secondary: const Icon(Icons.alarm),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chart widget copied from main_dashboard.dart for consistency.
class _AttendanceChart extends StatelessWidget {
  final List<int> data;
  final int total;
  final Color barColor;

  const _AttendanceChart({
    required this.data,
    required this.total,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: total.toDouble(),
        barTouchData: BarTouchData(
          enabled: false,
        ), // Disabled for persistent labels
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final dayStyle = TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                final valueStyle = TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );

                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                final index = value.toInt();
                if (index < 0 || index >= days.length) return const SizedBox();

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Column(
                    children: [
                      Text(days[index], style: dayStyle),
                      const SizedBox(height: 4),
                      Text(data[index].toString(), style: valueStyle),
                    ],
                  ),
                );
              },
              reservedSize: 65,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (index) {
          return _makeBar(index, data[index].toDouble(), barColor);
        }),
        gridData: const FlGridData(show: false),
      ),
      swapAnimationDuration: const Duration(milliseconds: 450),
      swapAnimationCurve: Curves.easeOut,
    );
  }

  BarChartGroupData _makeBar(int x, double y, Color color) {
    final barGradient = LinearGradient(
      colors: [color.withOpacity(0.8), color],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: barGradient,
          width: 18,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }
}

/// Tab 2: Teacher Check-in / Check-out
class _MyStatusTab extends StatefulWidget {
  const _MyStatusTab();

  @override
  State<_MyStatusTab> createState() => _MyStatusTabState();
}

class _MyStatusTabState extends State<_MyStatusTab> {
  bool _isCheckedIn = false;
  String _statusMessage = 'You are currently checked out.';

  void _toggleCheckIn() {
    setState(() {
      _isCheckedIn = !_isCheckedIn;
      if (_isCheckedIn) {
        _statusMessage = 'Checked in at ${TimeOfDay.now().format(context)}.';
      } else {
        _statusMessage = 'Checked out at ${TimeOfDay.now().format(context)}.';
      }
    });
    // todo: Integrate with backend/biometrics
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isCheckedIn ? Icons.check_circle_outline : Icons.highlight_off,
              color: _isCheckedIn ? Colors.green : Colors.red,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(_isCheckedIn ? Icons.logout : Icons.login),
                label: Text(_isCheckedIn ? 'Check Out' : 'Check In'),
                onPressed: _toggleCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCheckedIn
                      ? Colors.red.shade400
                      : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This action will be used for payroll and attendance integrity. In the future, this can be automated with biometrics.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab 3: Mark Attendance (for teachers)
class _MarkAttendanceTab extends StatelessWidget {
  const _MarkAttendanceTab();

  @override
  Widget build(BuildContext context) {
    // Placeholder data for classes
    final classes = [
      'Grade 5A - Mathematics',
      'Grade 7B - Science',
      'Grade 9 - History',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.class_outlined),
            title: Text(classes[index]),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // todo: Navigate to a detailed screen to mark attendance for this class
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening attendance for ${classes[index]}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Tab 4: Leave Management
class _LeaveManagementTab extends StatelessWidget {
  const _LeaveManagementTab();

  @override
  Widget build(BuildContext context) {
    // Placeholder data for leave requests
    final leaveRequests = [
      {
        'name': 'Uhuru Kenyatta (Student)',
        'reason': 'Sick Leave',
        'status': 'Pending',
      },
      {
        'name': 'Mr.Chengasia (Teacher)',
        'reason': 'Personal Leave',
        'status': 'Pending',
      },
      {
        'name': 'Lewis Ndungu (Student)',
        'reason': 'Family Event',
        'status': 'Approved',
      },
    ];

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: leaveRequests.length,
        itemBuilder: (context, index) {
          final request = leaveRequests[index];
          final isPending = request['status'] == 'Pending';

          return Card(
            child: ListTile(
              title: Text(request['name']!),
              subtitle: Text(request['reason']!),
              trailing: isPending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            // todo: Implement approve logic
                          },
                          tooltip: 'Approve',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            // todo: Implement reject logic
                          },
                          tooltip: 'Reject',
                        ),
                      ],
                    )
                  : Chip(
                      label: Text(request['status']!),
                      backgroundColor: Colors.grey.shade300,
                    ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // todo: Show a dialog or navigate to a screen to apply for leave
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening leave application form...')),
          );
        },
        label: const Text('Apply for Leave'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
