import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  // Logout function
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    // Navigate back to login and remove all previous routes
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<DashboardItem> dashboardItems = [
      // Student Information Core
      DashboardItem(
        icon: Icons.person_outline,
        title: 'Student Profile',
        description: 'Details, classes, and sections.',
        onTap: () {}, // todo: Navigate to Student Profile
      ),
      // Academics & Assignments
      DashboardItem(
        icon: Icons.menu_book_outlined,
        title: 'Academics',
        description: 'Assignments, syllabus, and results.',
        onTap: () {}, // todo: Navigate to Academics
      ),
      DashboardItem(
        icon: Icons.schedule_outlined,
        title: 'Timetable',
        description: 'View your weekly class schedule.',
        onTap: () {}, // todo: Navigate to Timetable
      ),
      // Financial Status
      DashboardItem(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Financials',
        description: 'Fee collections and due payments.',
        onTap: () {}, // todo: Navigate to Financials
      ),
      // Attendance & Behavior
      DashboardItem(
        icon: Icons.check_circle_outline,
        title: 'Attendance',
        description: 'Track attendance records.',
        onTap: () {}, // todo: Navigate to Attendance
      ),
      DashboardItem(
        icon: Icons.gavel_outlined,
        title: 'Behavior',
        description: 'View disciplinary records.',
        onTap: () {}, // todo: Navigate to Behavior
      ),
      // Self-Service Actions
      DashboardItem(
        icon: Icons.edit_calendar_outlined,
        title: 'Apply for Leave',
        description: 'Submit leave requests.',
        onTap: () {}, // todo: Navigate to Leave Application
      ),
      DashboardItem(
        icon: Icons.school_outlined,
        title: 'Admissions',
        description: 'Manage online admission forms.',
        onTap: () {}, // todo: Navigate to Admissions
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Notifications Hub
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // todo: Navigate to notifications screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              user?.email ?? 'User',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 cards per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: dashboardItems.length,
              itemBuilder: (context, index) {
                final item = dashboardItems[index];
                return DashboardCard(item: item);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardItem {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  DashboardItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.item});

  final DashboardItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
