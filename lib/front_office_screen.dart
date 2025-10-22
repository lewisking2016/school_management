import 'package:flutter/material.dart';

class FrontOfficeScreen extends StatefulWidget {
  const FrontOfficeScreen({super.key});

  @override
  State<FrontOfficeScreen> createState() => _FrontOfficeScreenState();
}

class _FrontOfficeScreenState extends State<FrontOfficeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Define the tabs for the Front Office module
  final List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.person_add_alt_1_outlined, 'label': 'Admission Enquiry'},
    {'icon': Icons.book_online_outlined, 'label': 'Visitor Book'},
    {'icon': Icons.phone_in_talk_outlined, 'label': 'Phone Call Log'},
    {'icon': Icons.outbox_outlined, 'label': 'Postal Dispatch'},
    {'icon': Icons.move_to_inbox_outlined, 'label': 'Postal Receive'},
    {'icon': Icons.report_problem_outlined, 'label': 'Complain'},
    {'icon': Icons.settings_outlined, 'label': 'Setup'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
      // The AppBar is integrated into the main dashboard, so we only need the TabBar.
      // If this screen were standalone, you would include an AppBar here.
      appBar: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: theme.colorScheme.primary,
        tabs: _tabs.map((tab) {
          return Tab(icon: Icon(tab['icon']), text: tab['label']);
        }).toList(),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _AdmissionEnquiryTab(), // Replaced with the new tab content
          _buildPlaceholderTab(
            icon: Icons.book_online_outlined,
            title: 'Visitor Book',
            description: 'Check-in and manage all incoming visitors here.',
          ),
          _buildPlaceholderTab(
            icon: Icons.phone_in_talk_outlined,
            title: 'Phone Call Log',
            description:
                'Track and manage all incoming and outgoing phone calls.',
          ),
          _buildPlaceholderTab(
            icon: Icons.outbox_outlined,
            title: 'Postal Dispatch',
            description: 'Manage all outgoing mail and package dispatches.',
          ),
          _buildPlaceholderTab(
            icon: Icons.move_to_inbox_outlined,
            title: 'Postal Receive',
            description: 'Manage all incoming mail and package receipts.',
          ),
          _buildPlaceholderTab(
            icon: Icons.report_problem_outlined,
            title: 'Complain',
            description:
                'Track and resolve complaints from students, parents, and staff.',
          ),
          _buildPlaceholderTab(
            icon: Icons.settings_outlined,
            title: 'Setup Front Office',
            description: 'Configure all front office operations and settings.',
          ),
        ],
      ),
    );
  }

  /// A generic placeholder widget for a tab's content.
  Widget _buildPlaceholderTab({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// New widget for the Admission Enquiry Tab
class _AdmissionEnquiryTab extends StatefulWidget {
  const _AdmissionEnquiryTab();

  @override
  State<_AdmissionEnquiryTab> createState() => _AdmissionEnquiryTabState();
}

class _AdmissionEnquiryTabState extends State<_AdmissionEnquiryTab> {
  // Dummy data for enquiries
  final List<Map<String, String>> _enquiries = [
    {
      'enquiryNo': 'ENQ001',
      'studentName': 'Alice Smithrowe',
      'fatherName': 'John Cina',
      'fatherPhone': '123-456-7890',
      'enquiryDate': '2023-10-20',
      'status': 'New',
      'source': 'Website',
    },
    {
      'enquiryNo': 'ENQ002',
      'studentName': 'Bob Kinaga',
      'fatherName': 'David Kinaga',
      'fatherPhone': '098-765-4321',
      'enquiryDate': '2023-10-18',
      'status': 'Contacted',
      'source': 'Referral',
    },
    {
      'enquiryNo': 'ENQ003',
      'studentName': 'Lewis Ndungu',
      'fatherName': 'Robert Ndungu',
      'fatherPhone': '111-222-3333',
      'enquiryDate': '2023-10-15',
      'status': 'Enrolled',
      'source': 'Walk-in',
    },
    {
      'enquiryNo': 'ENQ004',
      'studentName': 'Martin Sikuku',
      'fatherName': 'Steve Kimani',
      'fatherPhone': '444-555-6666',
      'enquiryDate': '2023-10-10',
      'status': 'New',
      'source': 'Advertisement',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int totalEnquiries = _enquiries.length;
    final int newEnquiries = _enquiries
        .where((e) => e['status'] == 'New')
        .length;
    final int enrolledEnquiries = _enquiries
        .where((e) => e['status'] == 'Enrolled')
        .length;
    final int contactedEnquiries = _enquiries
        .where((e) => e['status'] == 'Contacted')
        .length;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admission Enquiry Overview',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5, // Adjust aspect ratio for card size
              children: [
                _buildSummaryCard(
                  context,
                  'Total Enquiries',
                  totalEnquiries.toString(),
                  Icons.list_alt,
                  Colors.blue,
                ),
                _buildSummaryCard(
                  context,
                  'New Enquiries',
                  newEnquiries.toString(),
                  Icons.fiber_new,
                  Colors.orange,
                ),
                _buildSummaryCard(
                  context,
                  'Enrolled',
                  enrolledEnquiries.toString(),
                  Icons.school,
                  Colors.green,
                ),
                _buildSummaryCard(
                  context,
                  'Contacted',
                  contactedEnquiries.toString(),
                  Icons.phone_in_talk,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Enquiry Records',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Enquiry List/Table
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Enquiry No.')),
                    DataColumn(label: Text('Student Name')),
                    DataColumn(label: Text('Father\'s Name')),
                    DataColumn(label: Text('Father\'s Phone')),
                    DataColumn(label: Text('Enquiry Date')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Source')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _enquiries.map((enquiry) {
                    return DataRow(
                      cells: [
                        DataCell(Text(enquiry['enquiryNo']!)),
                        DataCell(Text(enquiry['studentName']!)),
                        DataCell(Text(enquiry['fatherName']!)),
                        DataCell(Text(enquiry['fatherPhone']!)),
                        DataCell(Text(enquiry['enquiryDate']!)),
                        DataCell(
                          Chip(
                            label: Text(enquiry['status']!),
                            backgroundColor: _getStatusColor(
                              enquiry['status']!,
                            ),
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                        DataCell(Text(enquiry['source']!)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () {
                                  // todo: Implement edit functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Edit ${enquiry['enquiryNo']}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () {
                                  // todo: Implement delete functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Delete ${enquiry['enquiryNo']}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // todo: Implement add new enquiry functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add New Enquiry form coming soon!')),
          );
        },
        label: const Text('Add New Enquiry'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return Colors.orange;
      case 'Contacted':
        return Colors.blue;
      case 'Enrolled':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
