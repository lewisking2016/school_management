import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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
    {'icon': Icons.dashboard_outlined, 'label': 'Overview'},
    {'icon': Icons.person_add_alt_1_outlined, 'label': 'Admission Enquiry'},
    {'icon': Icons.book_online_outlined, 'label': 'Visitor Book'},
    {'icon': Icons.phone_in_talk_outlined, 'label': 'Phone Call Log'},
    {'icon': Icons.outbox_outlined, 'label': 'Postal Dispatch'},
    {'icon': Icons.move_to_inbox_outlined, 'label': 'Postal Receive'},
    {'icon': Icons.report_problem_outlined, 'label': 'Complain'},
    {'icon': Icons.settings_outlined, 'label': 'Setup Front Office'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    // Add a listener to rebuild the FAB when the tab changes.
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Builds a FAB based on the currently selected tab.
  Widget? _buildFloatingActionButton() {
    final currentTabLabel = _tabs[_tabController.index]['label'];
    if (currentTabLabel == 'Admission Enquiry') {
      // This button is now moved inside the _AdmissionEnquiryTab widget.
      return null;
    } else if (currentTabLabel == 'Visitor Book') {
      // This button is now moved inside the _VisitorBookTab widget.
      return null;
    }
    return null;
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
          const _OverviewTab(), // New overview tab
          const _AdmissionEnquiryTab(), // Replaced with the new tab content
          const _VisitorBookTab(), // Replaced placeholder with the new tab content
          const _PhoneCallLogTab(),
          const _PostalDispatchTab(), // Replaced placeholder with the new tab content
          const _PostalReceiveTab(), // Replaced placeholder
          const _ComplainTab(), // New Complain Tab
          _buildPlaceholderTab(
            icon: Icons.settings_outlined,
            title: 'Setup Front Office',
            description: 'Configure all front office operations and settings.',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
  final List<Map<String, dynamic>> _summaryData = [];

  @override
  void initState() {
    super.initState();
    // Populate summary data here to avoid doing it in every build
    _summaryData.addAll([
      {
        'title': 'Total Enquiries',
        'icon': Icons.list_alt,
        'color': Colors.blue,
      },
      {
        'title': 'New Enquiries',
        'icon': Icons.fiber_new,
        'color': Colors.orange,
      },
      {'title': 'Enrolled', 'icon': Icons.school, 'color': Colors.green},
      {
        'title': 'Contacted',
        'icon': Icons.phone_in_talk,
        'color': Colors.purple,
      },
    ]);
  }

  void _editEnquiry(DocumentSnapshot enquiryDoc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _AddAdmissionEnquiryForm(enquiryDoc: enquiryDoc),
        );
      },
    );
  }

  Future<void> _deleteEnquiry(String docId, String studentName) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete the enquiry for "$studentName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('admission_enquiries')
            .doc(docId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enquiry record deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting enquiry: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('admission_enquiries')
              .orderBy('enquiryDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admission Enquiry Records',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  // Enquiry List/Table
                  if (docs.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.0),
                        child: Text('No admission enquiries found.'),
                      ),
                    )
                  else
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 12, // Reduced spacing
                          horizontalMargin: 8, // Reduced margins
                          dataRowMinHeight: 32, // Smaller row height
                          dataRowMaxHeight: 40, // Smaller max height
                          headingRowHeight: 36, // Smaller header height
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Enquiry No.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Student Name',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Father\'s Name',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Phone',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Date',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Source',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Actions',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          rows: docs.map((doc) {
                            final enquiry = doc.data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    enquiry['enquiryNo'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    enquiry['studentName'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    enquiry['fatherName'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    enquiry['fatherPhone'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    enquiry['enquiryDate'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        enquiry['status'] ?? '',
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      enquiry['status'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    enquiry['source'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          _editEnquiry(doc);
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          _deleteEnquiry(
                                            doc.id,
                                            enquiry['studentName'] ?? '',
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  // Add New Enquiry Button - Moved here from FAB
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                              ),
                              child: const _AddAdmissionEnquiryForm(),
                            );
                          },
                        ).then((value) {
                          if (value == true) {
                            // Data is refreshed automatically by StreamBuilder
                          }
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Enquiry'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSmallSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New widget for the Overview Tab
class _OverviewTab extends StatefulWidget {
  const _OverviewTab();

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  final List<Map<String, dynamic>> _summaryData = [];

  @override
  void initState() {
    super.initState();
    // Populate summary data for both admission enquiries and visitors
    _summaryData.addAll([
      // Admission Enquiry summaries
      {
        'title': 'Total Enquiries',
        'icon': Icons.list_alt,
        'color': Colors.blue,
        'collection': 'admission_enquiries',
        'field': 'total',
      },
      {
        'title': 'New Enquiries',
        'icon': Icons.fiber_new,
        'color': Colors.orange,
        'collection': 'admission_enquiries',
        'field': 'new',
      },
      {
        'title': 'Enrolled',
        'icon': Icons.school,
        'color': Colors.green,
        'collection': 'admission_enquiries',
        'field': 'enrolled',
      },
      {
        'title': 'Contacted',
        'icon': Icons.phone_in_talk,
        'color': Colors.purple,
        'collection': 'admission_enquiries',
        'field': 'contacted',
      },
      // Visitor Book summaries
      {
        'title': 'Total Visitors',
        'icon': Icons.groups_outlined,
        'color': Colors.blue,
        'collection': 'visitors',
        'field': 'total',
      },
      {
        'title': 'Currently In',
        'icon': Icons.login_outlined,
        'color': Colors.green,
        'collection': 'visitors',
        'field': 'checked_in',
      },
      {
        'title': 'Checked Out',
        'icon': Icons.logout_outlined,
        'color': Colors.orange,
        'collection': 'visitors',
        'field': 'checked_out',
      },
      {
        'title': 'Security Alerts',
        'icon': Icons.security_outlined,
        'color': Colors.red,
        'collection': 'visitors',
        'field': 'alerts',
      },
      // Phone Call Log summaries
      {
        'title': 'Total Calls',
        'icon': Icons.phone_outlined,
        'color': Colors.teal,
        'collection': 'phone_call_logs',
        'field': 'total',
      },
      {
        'title': 'Incoming Calls',
        'icon': Icons.call_received,
        'color': Colors.indigo,
        'collection': 'phone_call_logs',
        'field': 'incoming',
      },
      {
        'title': 'Outgoing Calls',
        'icon': Icons.call_made,
        'color': Colors.cyan,
        'collection': 'phone_call_logs',
        'field': 'outgoing',
      },
      {
        'title': 'Completed Calls',
        'icon': Icons.check_circle_outline,
        'color': Colors.green,
        'collection': 'phone_call_logs',
        'field': 'completed',
      },
      // Postal Receive summaries
      {
        'title': 'Today\'s Receipts',
        'icon': Icons.today_outlined,
        'color': Colors.blue,
        'collection': 'postal_receives',
        'field': 'today',
      },
      {
        'title': 'Pending Collection',
        'icon': Icons.hourglass_empty_outlined,
        'color': Colors.orange,
        'collection': 'postal_receives',
        'field': 'pending',
      },
      {
        'title': 'Delivered',
        'icon': Icons.check_circle_outline,
        'color': Colors.green,
        'collection': 'postal_receives',
        'field': 'delivered',
      },
      {
        'title': 'Packages',
        'icon': Icons.all_inbox_outlined,
        'color': Colors.purple,
        'collection': 'postal_receives',
        'field': 'total_packages',
        'isCount': true, // Custom field to indicate it's a count of packages
      },
      // Postal Dispatch summaries
      {
        'title': 'Today\'s Dispatches',
        'icon': Icons.today_outlined,
        'color': Colors.blue,
        'collection': 'postal_dispatches',
        'field': 'today',
      },
      {
        'title': 'In Transit',
        'icon': Icons.local_shipping_outlined,
        'color': Colors.orange,
        'collection': 'postal_dispatches',
        'field': 'in_transit',
      },
      {
        'title': 'Delivered',
        'icon': Icons.check_circle_outline,
        'color': Colors.green,
        'collection': 'postal_dispatches',
        'field': 'delivered',
      },
      // Complain summaries
      {
        'title': 'Open Complaints',
        'icon': Icons.folder_open_outlined,
        'color': Colors.orange,
        'collection': 'complaints',
        'field': 'open',
      },
      {
        'title': 'In Progress',
        'icon': Icons.hourglass_top_outlined,
        'color': Colors.blue,
        'collection': 'complaints',
        'field': 'in_progress',
      },
      {
        'title': 'Resolved',
        'icon': Icons.check_circle_outline,
        'color': Colors.green,
      },
      {
        'title': 'Total Value',
        'icon': Icons.attach_money_outlined,
        'color': Colors.purple,
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('admission_enquiries')
              .snapshots(),
          builder: (context, admissionSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('visitors')
                  .snapshots(),
              builder: (context, visitorSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('phone_call_logs')
                      .snapshots(),
                  builder: (context, phoneCallSnapshot) {
                    // Add another StreamBuilder for postal_receives
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('postal_dispatches')
                          .snapshots(),
                      builder: (context, postalDispatchSnapshot) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('postal_receives')
                              .snapshots(),
                          builder: (context, postalReceiveSnapshot) {
                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('complaints')
                                  .snapshots(),
                              builder: (context, complaintSnapshot) {
                                if (admissionSnapshot.hasError ||
                                    visitorSnapshot.hasError ||
                                    phoneCallSnapshot.hasError ||
                                    postalDispatchSnapshot.hasError ||
                                    postalReceiveSnapshot.hasError ||
                                    complaintSnapshot.hasError) {
                                  return const Center(
                                    child: Text(
                                      'Something went wrong loading data.',
                                    ),
                                  );
                                }

                                if (admissionSnapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    visitorSnapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    phoneCallSnapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    postalDispatchSnapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    postalReceiveSnapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    complaintSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final admissionDocs =
                                    admissionSnapshot.data!.docs;
                                final visitorDocs = visitorSnapshot.data!.docs;
                                final phoneCallDocs =
                                    phoneCallSnapshot.data?.docs ?? [];
                                final postalDispatchDocs =
                                    postalDispatchSnapshot.data?.docs ?? [];
                                final postalReceiveDocs =
                                    postalReceiveSnapshot.data?.docs ?? [];
                                final complaintDocs =
                                    complaintSnapshot.data?.docs ?? [];

                                // Calculate summary data
                                final int totalEnquiries = admissionDocs.length;
                                final int newEnquiries = admissionDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['status'] == 'New',
                                    )
                                    .length;
                                final int enrolledEnquiries = admissionDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['status'] ==
                                          'Enrolled',
                                    )
                                    .length;
                                final int contactedEnquiries = admissionDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['status'] ==
                                          'Contacted',
                                    )
                                    .length;

                                final int totalVisitors = visitorDocs.length;
                                final int currentlyIn = visitorDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['status'] ==
                                          'Checked In',
                                    )
                                    .length;
                                final int checkedOut = visitorDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['status'] ==
                                          'Checked Out',
                                    )
                                    .length;
                                const int securityAlerts = 0; // Placeholder

                                // Phone Call Log calculations
                                final int totalCalls = phoneCallDocs.length;
                                final int incomingCalls = phoneCallDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['callType'] ==
                                          'Incoming',
                                    )
                                    .length;
                                final int outgoingCalls = phoneCallDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['callType'] ==
                                          'Outgoing',
                                    )
                                    .length;
                                final int completedCalls = phoneCallDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['callStatus'] ==
                                          'Completed',
                                    )
                                    .length;

                                // Postal Dispatch calculations
                                final today = DateFormat(
                                  'yyyy-MM-dd',
                                ).format(DateTime.now());
                                final int todaysDispatches = postalDispatchDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['dispatchDate'] ==
                                          today,
                                    )
                                    .length;
                                final int inTransit = postalDispatchDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['status'] ==
                                          'In Transit',
                                    )
                                    .length;
                                final int delivered = postalDispatchDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['status'] ==
                                          'Delivered',
                                    )
                                    .length;
                                final double totalValue = postalDispatchDocs
                                    .fold(0.0, (totalSum, doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final amount =
                                          data['postageAmount'] ?? 0.0;
                                      return totalSum +
                                          (amount is int
                                              ? amount.toDouble()
                                              : amount);
                                    });

                                // Postal Receive calculations
                                final int todaysReceipts = postalReceiveDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['receivedDate'] ==
                                          today,
                                    )
                                    .length;
                                final int pendingCollection = postalReceiveDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['status'] ==
                                          'Pending Collection',
                                    )
                                    .length;
                                final int deliveredReceipts = postalReceiveDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['status'] ==
                                          'Delivered',
                                    )
                                    .length;
                                final int totalPackages = postalReceiveDocs
                                    .length; // Assuming 'Packages' means total received items

                                // Complaint calculations
                                final int openComplaints = complaintDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['status'] == 'Open',
                                    )
                                    .length;
                                final int inProgressComplaints = complaintDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['status'] ==
                                          'In Progress',
                                    )
                                    .length;
                                final int resolvedComplaints = complaintDocs
                                    .where(
                                      (d) =>
                                          (d.data() as Map)['status'] ==
                                          'Resolved',
                                    )
                                    .length;
                                final int totalComplaints =
                                    complaintDocs.length;

                                final values = [
                                  totalEnquiries,
                                  newEnquiries,
                                  enrolledEnquiries,
                                  contactedEnquiries,
                                  totalVisitors,
                                  currentlyIn,
                                  checkedOut,
                                  securityAlerts,
                                  totalCalls,
                                  incomingCalls,
                                  outgoingCalls,
                                  completedCalls,
                                  todaysDispatches,
                                  inTransit,
                                  delivered,
                                  int.parse(totalValue.toStringAsFixed(0)),
                                  todaysReceipts,
                                  pendingCollection,
                                  deliveredReceipts,
                                  totalPackages,
                                  openComplaints,
                                  inProgressComplaints,
                                  resolvedComplaints,
                                  totalComplaints,
                                ];

                                final admissionSummaryItems = _summaryData
                                    .where(
                                      (item) =>
                                          item['collection'] ==
                                          'admission_enquiries',
                                    )
                                    .toList();
                                final visitorSummaryItems = _summaryData
                                    .where(
                                      (item) =>
                                          item['collection'] == 'visitors',
                                    )
                                    .toList();
                                final phoneLogSummaryItems = _summaryData
                                    .where(
                                      (item) =>
                                          item['collection'] ==
                                          'phone_call_logs',
                                    )
                                    .toList();
                                final postalDispatchSummaryItems = _summaryData
                                    .where(
                                      (item) =>
                                          item['collection'] ==
                                          'postal_dispatches',
                                    )
                                    .toList();
                                final postalDispatchValueItem = _summaryData
                                    .firstWhere(
                                      (item) => item['title'] == 'Total Value',
                                    );
                                final postalReceiveSummaryItems = _summaryData
                                    .where(
                                      (item) =>
                                          item['collection'] ==
                                          'postal_receives',
                                    )
                                    .toList();
                                final complainSummaryItems = _summaryData
                                    .where(
                                      (item) =>
                                          item['collection'] == 'complaints',
                                    )
                                    .toList();

                                return SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                        0.04, // 4% of screen width
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                        0.02, // 2% of screen height
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Front Office Overview',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.02,
                                      ),

                                      // Admission Enquiry Overview
                                      _buildOverviewSection(
                                        title: 'Admission Enquiry Overview',
                                        items: admissionSummaryItems,
                                        values: values.sublist(0, 4),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.03,
                                      ),

                                      // Visitor Book Overview
                                      _buildOverviewSection(
                                        title: 'Visitor Book Overview',
                                        items: visitorSummaryItems,
                                        values: values.sublist(4, 8),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.03,
                                      ),

                                      // Phone Call Log Overview
                                      _buildOverviewSection(
                                        title: 'Phone Call Log Overview',
                                        items: phoneLogSummaryItems,
                                        values: values.sublist(8, 12),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.03,
                                      ),

                                      // Postal Receive Overview
                                      _buildOverviewSection(
                                        title: 'Postal Receive Overview',
                                        items: postalReceiveSummaryItems,
                                        values: values.sublist(16, 20),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.03,
                                      ),

                                      // Postal Dispatch Overview
                                      _buildOverviewSection(
                                        title: 'Postal Dispatch Overview',
                                        items:
                                            postalDispatchSummaryItems +
                                            [
                                              postalDispatchValueItem,
                                            ], // Keep this as it is
                                        values: values.sublist(12, 16),
                                        valuePrefix:
                                            postalDispatchSummaryItems.length,
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.03,
                                      ),

                                      // Complain Overview
                                      _buildOverviewSection(
                                        title: 'Complaints Overview',
                                        items: complainSummaryItems,
                                        values: values.sublist(20, 24),
                                      ),

                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.04,
                                      ), // 4% of screen height
                                      // Quick Actions
                                      Text(
                                        'Quick Actions',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.02,
                                      ), // 2% of screen height
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final screenWidth =
                                              constraints.maxWidth;
                                          if (screenWidth >= 600) {
                                            // Tablet and larger screens - horizontal layout
                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: _buildQuickActionCard(
                                                    'New Enquiry',
                                                    Icons
                                                        .person_add_alt_1_outlined,
                                                    Colors.blue,
                                                    () =>
                                                        DefaultTabController.of(
                                                          context,
                                                        ).animateTo(1),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.03,
                                                ), // 3% of screen width
                                                Expanded(
                                                  child: _buildQuickActionCard(
                                                    'Check In Visitor',
                                                    Icons.login_outlined,
                                                    Colors.green,
                                                    () =>
                                                        DefaultTabController.of(
                                                          context,
                                                        ).animateTo(2),
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            // Mobile screens - vertical layout
                                            return Column(
                                              children: [
                                                _buildQuickActionCard(
                                                  'New Enquiry',
                                                  Icons
                                                      .person_add_alt_1_outlined,
                                                  Colors.blue,
                                                  () => DefaultTabController.of(
                                                    context,
                                                  ).animateTo(1),
                                                ),
                                                SizedBox(
                                                  height:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height *
                                                      0.02,
                                                ),
                                                _buildQuickActionCard(
                                                  'Check In Visitor',
                                                  Icons.login_outlined,
                                                  Colors.green,
                                                  () => DefaultTabController.of(
                                                    context,
                                                  ).animateTo(2),
                                                ),
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewSection({
    required String title,
    required List<Map<String, dynamic>> items,
    required List<int> values,
    int? valuePrefix,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            int crossAxisCount;

            if (screenWidth >= 600) {
              crossAxisCount = 4; // Tablets and larger screens
            } else {
              crossAxisCount = 2; // Mobile screens
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: screenWidth * 0.03,
                mainAxisSpacing: screenWidth * 0.03,
                childAspectRatio: 1, // Make cards square
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final valueString =
                    (valuePrefix != null && index == valuePrefix)
                    ? '\$${values[index]}'
                    : values[index].toString();
                return _buildSmallSummaryCard(
                  item['title'],
                  valueString,
                  item['icon'],
                  item['color'],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSmallSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 50, // Smaller fixed width for more cards per row
      height: 50, // Smaller fixed height for more cards per row
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ), // Even smaller border radius
        child: Padding(
          padding: const EdgeInsets.all(4), // Minimal padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color), // Larger, more visible icon
              const SizedBox(height: 1), // Minimal spacing
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 12, // Larger, more readable font
                  ),
                ),
              ),
              const SizedBox(height: 0.5), // Minimal spacing
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 8, // Larger, more readable font
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
          child: Column(
            children: [
              Icon(icon, size: isSmallScreen ? 28 : 32, color: color),
              SizedBox(height: screenWidth * 0.02), // 2% of screen width
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New widget for the Phone Call Log Tab
class _PhoneCallLogTab extends StatefulWidget {
  const _PhoneCallLogTab();

  @override
  State<_PhoneCallLogTab> createState() => _PhoneCallLogTabState();
}

class _PhoneCallLogTabState extends State<_PhoneCallLogTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('phone_call_logs')
              .orderBy('callDateTime', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Call Records',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  // Call Log List/Table
                  if (docs.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.0),
                        child: Text('No call logs found.'),
                      ),
                    )
                  else
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 12, // Reduced spacing
                          horizontalMargin: 8, // Reduced margins
                          dataRowMinHeight: 32, // Smaller row height
                          dataRowMaxHeight: 40, // Smaller max height
                          headingRowHeight: 36, // Smaller header height
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Caller Name',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Phone',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Type',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Duration',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Purpose',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Department',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Priority',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Date/Time',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Actions',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          rows: docs.map((doc) {
                            final callLog = doc.data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    callLog['callerName'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    callLog['phoneNumber'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: callLog['callType'] == 'Incoming'
                                          ? Colors.green
                                          : Colors.blue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      callLog['callType'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    callLog['duration'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    callLog['purpose'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    callLog['department'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(
                                        callLog['priority'] ?? '',
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      callLog['priority'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        callLog['callStatus'] ?? '',
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      callLog['callStatus'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    callLog['callDateTime'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          _editCallLog(doc);
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          _deleteCallLog(
                                            doc.id,
                                            callLog['callerName'] ?? '',
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  // Log New Call Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                              ),
                              child: const _AddPhoneCallLogForm(),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.add_ic_call),
                      label: const Text('Log New Call'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _editCallLog(DocumentSnapshot callLogDoc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _AddPhoneCallLogForm(callLogDoc: callLogDoc),
        );
      },
    );
  }

  Future<void> _deleteCallLog(String docId, String callerName) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete the call log for "$callerName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('phone_call_logs')
            .doc(docId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Call log deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting call log: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ignore: unused_element
  Widget _buildSmallSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      // Removed screenWidth and isSmallScreen as they were unused in this specific method.
      width: 50, // Smaller fixed width for more cards per row
      height: 50, // Smaller fixed height for more cards per row
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ), // Even smaller border radius
        child: Padding(
          padding: const EdgeInsets.all(4), // Minimal padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color), // Larger, more visible icon
              const SizedBox(height: 1), // Minimal spacing
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 12, // Larger, more readable font
                  ),
                ),
              ),
              const SizedBox(height: 0.5), // Minimal spacing
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 8, // Larger, more readable font
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _getPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return Colors.red;
    case 'medium':
      return Colors.orange;
    case 'low':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

// New widget for the Add Phone Call Log Form
class _AddPhoneCallLogForm extends StatefulWidget {
  final DocumentSnapshot? callLogDoc;
  const _AddPhoneCallLogForm({this.callLogDoc});

  @override
  State<_AddPhoneCallLogForm> createState() => _AddPhoneCallLogFormState();
}

class _AddPhoneCallLogFormState extends State<_AddPhoneCallLogForm> {
  final _formKey = GlobalKey<FormState>();
  final _callerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _durationController = TextEditingController();
  final _purposeController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCallType;
  String? _selectedDepartment;
  String? _selectedPriority;
  String? _selectedCallStatus;

  // Dummy data for dropdowns
  final List<String> _callTypes = ['Incoming', 'Outgoing'];
  final List<String> _departments = [
    'Principal\'s Office',
    'Accounts',
    'Admissions',
    'HR',
    'IT',
    'Academic',
    'Administration',
  ];
  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _callStatuses = [
    'Completed',
    'Missed',
    'Busy',
    'No Answer',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.callLogDoc != null) {
      final data = widget.callLogDoc!.data() as Map<String, dynamic>;
      _callerNameController.text = data['callerName'] ?? '';
      _phoneController.text = data['phoneNumber'] ?? '';
      _durationController.text = data['duration'] ?? '';
      _purposeController.text = data['purpose'] ?? '';
      _notesController.text = data['notes'] ?? '';
      _selectedCallType = data['callType'];
      _selectedDepartment = data['department'];
      _selectedPriority = data['priority'];
      _selectedCallStatus = data['callStatus'];
    } else {
      // Set defaults for new call log
      _selectedCallType = 'Incoming';
      _selectedPriority = 'Medium';
      _selectedCallStatus = 'Completed';
    }
  }

  @override
  void dispose() {
    _callerNameController.dispose();
    _phoneController.dispose();
    _durationController.dispose();
    _purposeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCallLog() async {
    if (_formKey.currentState!.validate()) {
      final callLogData = {
        'callerName': _callerNameController.text,
        'phoneNumber': _phoneController.text,
        'callType': _selectedCallType,
        'duration': _durationController.text,
        'purpose': _purposeController.text,
        'department': _selectedDepartment,
        'priority': _selectedPriority,
        'callStatus': _selectedCallStatus,
        'notes': _notesController.text,
      };

      try {
        final firestore = FirebaseFirestore.instance;
        String successMessage;

        if (widget.callLogDoc == null) {
          // Creating a new call log
          callLogData['callDateTime'] = DateFormat(
            'yyyy-MM-dd HH:mm',
          ).format(DateTime.now());
          await firestore.collection('phone_call_logs').add(callLogData);
          successMessage = 'Call log saved successfully!';
        } else {
          // Updating an existing call log
          await firestore
              .collection('phone_call_logs')
              .doc(widget.callLogDoc!.id)
              .update(callLogData);
          successMessage = 'Call log updated successfully!';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Pop and indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save call log: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.callLogDoc == null ? 'Log New Call' : 'Edit Call Log',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _callerNameController,
                decoration: const InputDecoration(labelText: 'Caller Name*'),
                validator: (value) =>
                    value!.isEmpty ? 'Caller name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number*'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCallType,
                decoration: const InputDecoration(labelText: 'Call Type*'),
                items: _callTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedCallType = value),
                validator: (value) =>
                    value == null ? 'Please select call type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  hintText: 'e.g., 5 min',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose of Call*',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Purpose is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(labelText: 'Department'),
                items: _departments
                    .map(
                      (dept) =>
                          DropdownMenuItem(value: dept, child: Text(dept)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedDepartment = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: _priorities
                    .map(
                      (priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedPriority = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCallStatus,
                decoration: const InputDecoration(labelText: 'Call Status'),
                items: _callStatuses
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCallStatus = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Call Notes',
                  hintText: 'Details of the call discussion...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveCallLog,
                    child: Text(
                      widget.callLogDoc == null
                          ? 'Save Call Log'
                          : 'Save Changes',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New widget for the Postal Dispatch Tab
class _PostalDispatchTab extends StatefulWidget {
  const _PostalDispatchTab();

  @override
  State<_PostalDispatchTab> createState() => _PostalDispatchTabState();
}

class _PostalDispatchTabState extends State<_PostalDispatchTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('postal_dispatches')
              .orderBy('dispatchDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Something went wrong: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Postal Dispatch Records',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  if (docs.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.0),
                        child: Text('No postal dispatches found.'),
                      ),
                    )
                  else
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 12,
                          horizontalMargin: 8,
                          dataRowMinHeight: 32,
                          dataRowMaxHeight: 40,
                          headingRowHeight: 36,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Recipient',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Address',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Type',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Priority',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Courier',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Amount',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Actions',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          rows: docs.map((doc) {
                            final dispatch = doc.data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    dispatch['recipientName'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    dispatch['recipientAddress'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    dispatch['dispatchType'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(
                                        dispatch['priority'] ?? '',
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      dispatch['priority'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    dispatch['courierService'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '\$${(dispatch['postageAmount'] ?? 0.0).toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        dispatch['status'] ?? '',
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      dispatch['status'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _editDispatch(doc),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _deleteDispatch(
                                          doc.id,
                                          dispatch['recipientName'] ?? '',
                                        ),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: const _AddPostalDispatchForm(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Dispatch'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _editDispatch(DocumentSnapshot dispatchDoc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AddPostalDispatchForm(dispatchDoc: dispatchDoc),
      ),
    );
  }

  Future<void> _deleteDispatch(String docId, String recipientName) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete the dispatch for "$recipientName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('postal_dispatches')
            .doc(docId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dispatch record deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting dispatch: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// New widget for the Add Postal Dispatch Form
class _AddPostalDispatchForm extends StatefulWidget {
  final DocumentSnapshot? dispatchDoc;
  const _AddPostalDispatchForm({this.dispatchDoc});

  @override
  State<_AddPostalDispatchForm> createState() => _AddPostalDispatchFormState();
}

class _AddPostalDispatchFormState extends State<_AddPostalDispatchForm> {
  final _formKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _recipientAddressController = TextEditingController();
  final _emailController = TextEditingController();
  final _postageAmountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _remarksController = TextEditingController();
  final _expectedDeliveryController = TextEditingController();

  String? _selectedDispatchType;
  String? _selectedPriority;
  String? _selectedCourier;
  String? _selectedDepartment;

  final List<String> _dispatchTypes = [
    'Document',
    'Parcel',
    'Letter',
    'Package',
  ];
  final List<String> _priorities = ['Normal', 'High', 'Urgent'];
  final List<String> _courierServices = ['FedEx', 'UPS', 'DHL', 'Local Post'];
  final List<String> _departments = [
    'Administration',
    'Accounts',
    'Admissions',
    'HR',
    'Principal\'s Office',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.dispatchDoc != null) {
      final data = widget.dispatchDoc!.data() as Map<String, dynamic>;
      _recipientNameController.text = data['recipientName'] ?? '';
      _phoneController.text = data['phoneNumber'] ?? '';
      _recipientAddressController.text = data['recipientAddress'] ?? '';
      _emailController.text = data['email'] ?? '';
      _postageAmountController.text = (data['postageAmount'] ?? 0.0).toString();
      _descriptionController.text = data['description'] ?? '';
      _remarksController.text = data['remarks'] ?? '';
      _expectedDeliveryController.text = data['expectedDelivery'] ?? '';
      _selectedDispatchType = data['dispatchType'];
      _selectedPriority = data['priority'];
      _selectedCourier = data['courierService'];
      _selectedDepartment = data['senderDepartment'];
    } else {
      _selectedPriority = 'Normal';
    }
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _phoneController.dispose();
    _recipientAddressController.dispose();
    _emailController.dispose();
    _postageAmountController.dispose();
    _descriptionController.dispose();
    _remarksController.dispose();
    _expectedDeliveryController.dispose();
    super.dispose();
  }

  Future<void> _saveDispatch() async {
    if (_formKey.currentState!.validate()) {
      final dispatchData = {
        'recipientName': _recipientNameController.text,
        'phoneNumber': _phoneController.text,
        'recipientAddress': _recipientAddressController.text,
        'email': _emailController.text,
        'dispatchType': _selectedDispatchType,
        'priority': _selectedPriority,
        'expectedDelivery': _expectedDeliveryController.text,
        'courierService': _selectedCourier,
        'senderDepartment': _selectedDepartment,
        'postageAmount': double.tryParse(_postageAmountController.text) ?? 0.0,
        'description': _descriptionController.text,
        'remarks': _remarksController.text,
      };

      try {
        final firestore = FirebaseFirestore.instance;
        String successMessage;

        if (widget.dispatchDoc == null) {
          dispatchData['dispatchDate'] = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.now());
          dispatchData['status'] = 'In Transit';
          await firestore.collection('postal_dispatches').add(dispatchData);
          successMessage = 'Dispatch created successfully!';
        } else {
          await firestore
              .collection('postal_dispatches')
              .doc(widget.dispatchDoc!.id)
              .update(dispatchData);
          successMessage = 'Dispatch updated successfully!';
        }

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save dispatch: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.dispatchDoc == null
                    ? 'New Postal Dispatch'
                    : 'Edit Postal Dispatch',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _recipientNameController,
                decoration: const InputDecoration(labelText: 'Recipient Name*'),
                validator: (v) =>
                    v!.isEmpty ? 'Recipient name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _recipientAddressController,
                decoration: const InputDecoration(
                  labelText: 'Recipient Address*',
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Recipient address is required' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDispatchType,
                      decoration: const InputDecoration(
                        labelText: 'Dispatch Type*',
                      ),
                      items: _dispatchTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedDispatchType = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: _priorities
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPriority = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expectedDeliveryController,
                      decoration: const InputDecoration(
                        labelText: 'Expected Delivery',
                        hintText: 'MM/DD/YYYY',
                      ),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          _expectedDeliveryController.text = DateFormat(
                            'MM/dd/yyyy',
                          ).format(date);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCourier,
                      decoration: const InputDecoration(
                        labelText: 'Courier Service',
                      ),
                      items: _courierServices
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCourier = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Sender Department',
                      ),
                      items: _departments
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDepartment = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _postageAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Postage Amount (\$)',
                        prefixText: '\$',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  hintText: 'Brief description of contents...',
                ),
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  hintText: 'Additional notes...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveDispatch,
                    child: Text(
                      widget.dispatchDoc == null
                          ? 'Create Dispatch'
                          : 'Save Changes',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New widget for the Postal Receive Tab
class _PostalReceiveTab extends StatefulWidget {
  const _PostalReceiveTab();

  @override
  State<_PostalReceiveTab> createState() => _PostalReceiveTabState();
}

class _PostalReceiveTabState extends State<_PostalReceiveTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('postal_receives')
              .orderBy('receivedDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Something went wrong: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Postal Receive Records',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  if (docs.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.0),
                        child: Text('No postal receipts found.'),
                      ),
                    )
                  else
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 12,
                          horizontalMargin: 8,
                          dataRowMinHeight: 32,
                          dataRowMaxHeight: 40,
                          headingRowHeight: 36,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Sender',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Recipient',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Mail Type',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Priority',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Tracking No.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Courier',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Received Date',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Actions',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          rows: docs.map((doc) {
                            final receipt = doc.data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    receipt['senderName'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    receipt['recipientName'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    receipt['mailType'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(
                                        receipt['priority'] ?? '',
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      receipt['priority'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    receipt['trackingNumber'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    receipt['courierService'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    receipt['receivedDate'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        receipt['status'] ?? '',
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      receipt['status'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _editReceipt(doc),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _deleteReceipt(
                                          doc.id,
                                          receipt['recipientName'] ?? '',
                                        ),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: const _AddPostalReceiveForm(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Register New Receipt'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _editReceipt(DocumentSnapshot receiptDoc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AddPostalReceiveForm(receiptDoc: receiptDoc),
      ),
    );
  }

  Future<void> _deleteReceipt(String docId, String recipientName) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete the receipt for "$recipientName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('postal_receives')
            .doc(docId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receipt record deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting receipt: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// New widget for the Add Postal Receive Form
class _AddPostalReceiveForm extends StatefulWidget {
  final DocumentSnapshot? receiptDoc;
  const _AddPostalReceiveForm({this.receiptDoc});

  @override
  State<_AddPostalReceiveForm> createState() => _AddPostalReceiveFormState();
}

class _AddPostalReceiveFormState extends State<_AddPostalReceiveForm> {
  final _formKey = GlobalKey<FormState>();
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _senderAddressController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _trackingNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _remarksController = TextEditingController();

  String? _selectedMailType;
  String? _selectedPriority;
  String? _selectedRecipientDepartment;
  String? _selectedCourierService;

  final List<String> _mailTypes = ['Document', 'Package', 'Letter', 'Other'];
  final List<String> _priorities = ['Normal', 'High', 'Urgent'];
  final List<String> _departments = [
    'Administration',
    'Accounts',
    'Admissions',
    'HR',
    'Principal\'s Office',
  ];
  final List<String> _courierServices = ['FedEx', 'UPS', 'DHL', 'Local Post'];

  @override
  void initState() {
    super.initState();
    if (widget.receiptDoc != null) {
      final data = widget.receiptDoc!.data() as Map<String, dynamic>;
      _senderNameController.text = data['senderName'] ?? '';
      _senderPhoneController.text = data['senderPhone'] ?? '';
      _senderAddressController.text = data['senderAddress'] ?? '';
      _recipientNameController.text = data['recipientName'] ?? '';
      _trackingNumberController.text = data['trackingNumber'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _remarksController.text = data['remarks'] ?? '';
      _selectedMailType = data['mailType'];
      _selectedPriority = data['priority'];
      _selectedRecipientDepartment = data['recipientDepartment'];
      _selectedCourierService = data['courierService'];
    } else {
      _selectedPriority = 'Normal';
    }
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _senderAddressController.dispose();
    _recipientNameController.dispose();
    _trackingNumberController.dispose();
    _descriptionController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _saveReceipt() async {
    if (_formKey.currentState!.validate()) {
      final receiptData = {
        'senderName': _senderNameController.text,
        'senderPhone': _senderPhoneController.text,
        'senderAddress': _senderAddressController.text,
        'mailType': _selectedMailType,
        'priority': _selectedPriority,
        'recipientDepartment': _selectedRecipientDepartment,
        'recipientName': _recipientNameController.text,
        'trackingNumber': _trackingNumberController.text,
        'courierService': _selectedCourierService,
        'description': _descriptionController.text,
        'remarks': _remarksController.text,
      };

      try {
        final firestore = FirebaseFirestore.instance;
        String successMessage;

        if (widget.receiptDoc == null) {
          receiptData['receivedDate'] = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.now());
          receiptData['status'] =
              'Pending Collection'; // Default status for new receipts
          await firestore.collection('postal_receives').add(receiptData);
          successMessage = 'Receipt registered successfully!';
        } else {
          await firestore
              .collection('postal_receives')
              .doc(widget.receiptDoc!.id)
              .update(receiptData);
          successMessage = 'Receipt updated successfully!';
        }

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save receipt: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.receiptDoc == null
                    ? 'Register New Receipt'
                    : 'Edit Receipt',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _senderNameController,
                decoration: const InputDecoration(labelText: 'Sender Name*'),
                validator: (v) => v!.isEmpty ? 'Sender name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senderPhoneController,
                decoration: const InputDecoration(labelText: 'Sender Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senderAddressController,
                decoration: const InputDecoration(labelText: 'Sender Address'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMailType,
                      decoration: const InputDecoration(
                        labelText: 'Mail Type*',
                      ),
                      items: _mailTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedMailType = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: _priorities
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPriority = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRecipientDepartment,
                decoration: const InputDecoration(
                  labelText: 'Recipient Department*',
                ),
                items: _departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedRecipientDepartment = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _recipientNameController,
                decoration: const InputDecoration(labelText: 'Recipient Name*'),
                validator: (v) =>
                    v!.isEmpty ? 'Recipient name is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _trackingNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Tracking Number',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCourierService,
                      decoration: const InputDecoration(
                        labelText: 'Courier Service',
                      ),
                      items: _courierServices
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCourierService = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  hintText: 'Brief description of contents...',
                ),
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  hintText: 'Additional notes...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveReceipt,
                    child: Text(
                      widget.receiptDoc == null
                          ? 'Register Receipt'
                          : 'Save Changes',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New widget for the Complain Tab
class _ComplainTab extends StatefulWidget {
  const _ComplainTab();

  @override
  State<_ComplainTab> createState() => _ComplainTabState();
}

class _ComplainTabState extends State<_ComplainTab> {
  void _editComplaint(DocumentSnapshot complaintDoc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AddComplaintForm(complaintDoc: complaintDoc),
      ),
    );
  }

  Future<void> _deleteComplaint(String docId, String subject) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete the complaint: "$subject"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('complaints')
            .doc(docId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting complaint: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('complaints')
              .orderBy('complaintDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Something went wrong: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complaint Records',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  if (docs.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.0),
                        child: Text('No complaints found.'),
                      ),
                    )
                  else
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Complaint #')),
                            DataColumn(label: Text('Complainer')),
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Subject')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Assigned To')),
                            DataColumn(label: Text('Priority')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: docs.map((doc) {
                            final complaint =
                                doc.data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(Text(complaint['complaintNo'] ?? '')),
                                DataCell(
                                  Text(complaint['complainerName'] ?? ''),
                                ),
                                DataCell(
                                  Text(complaint['complainerType'] ?? ''),
                                ),
                                DataCell(Text(complaint['subject'] ?? '')),
                                DataCell(
                                  Text(complaint['complaintDate'] ?? ''),
                                ),
                                DataCell(
                                  Text(
                                    complaint['assignedDepartment'] ?? 'N/A',
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(
                                        complaint['priority'] ?? '',
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      complaint['priority'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        complaint['status'] ?? '',
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      complaint['status'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _editComplaint(doc),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteComplaint(
                                          doc.id,
                                          complaint['subject'] ?? '',
                                        ),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: const _AddComplaintForm(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Register New Complaint'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// New widget for the Add Complaint Form
class _AddComplaintForm extends StatefulWidget {
  final DocumentSnapshot? complaintDoc;
  const _AddComplaintForm({this.complaintDoc});

  @override
  State<_AddComplaintForm> createState() => _AddComplaintFormState();
}

class _AddComplaintFormState extends State<_AddComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  final _complainerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _remarksController = TextEditingController();
  final _resolutionDateController = TextEditingController();

  String? _selectedComplainerType;
  String? _selectedCategory;
  String? _selectedPriority;
  String? _selectedDepartment;
  bool _followUpRequired = false;

  final List<String> _complainerTypes = [
    'Parent',
    'Student',
    'Teacher',
    'Staff',
    'Other',
  ];
  final List<String> _categories = [
    'Academic',
    'Infrastructure',
    'Fees',
    'Transport',
    'Other',
  ];
  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _departments = [
    'Administration',
    'Accounts',
    'Academic Head',
    'IT Support',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.complaintDoc != null) {
      final data = widget.complaintDoc!.data() as Map<String, dynamic>;
      _complainerNameController.text = data['complainerName'] ?? '';
      _phoneController.text = data['phoneNumber'] ?? '';
      _emailController.text = data['email'] ?? '';
      _subjectController.text = data['subject'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _remarksController.text = data['remarks'] ?? '';
      _resolutionDateController.text = data['expectedResolutionDate'] ?? '';
      _selectedComplainerType = data['complainerType'];
      _selectedCategory = data['category'];
      _selectedPriority = data['priority'];
      _selectedDepartment = data['assignedDepartment'];
      _followUpRequired = data['followUpRequired'] ?? false;
    } else {
      _selectedComplainerType = 'Parent';
      _selectedCategory = 'Academic';
      _selectedPriority = 'Medium';
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    super.dispose();
  }

  Future<void> _saveComplaint() async {
    if (_formKey.currentState!.validate()) {
      final complaintData = {
        'complainerName': _complainerNameController.text,
        'phoneNumber': _phoneController.text,
        'email': _emailController.text,
        'complainerType': _selectedComplainerType,
        'category': _selectedCategory,
        'priority': _selectedPriority,
        'assignedDepartment': _selectedDepartment,
        'expectedResolutionDate': _resolutionDateController.text,
        'subject': _subjectController.text,
        'description': _descriptionController.text,
        'remarks': _remarksController.text,
        'followUpRequired': _followUpRequired,
      };

      try {
        final firestore = FirebaseFirestore.instance;
        String successMessage;

        if (widget.complaintDoc == null) {
          const uuid = Uuid();
          complaintData['complaintNo'] =
              'COM-${uuid.v4().substring(0, 6).toUpperCase()}';
          complaintData['complaintDate'] = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.now());
          complaintData['status'] = 'Open';
          await firestore.collection('complaints').add(complaintData);
          successMessage = 'Complaint registered successfully!';
        } else {
          await firestore
              .collection('complaints')
              .doc(widget.complaintDoc!.id)
              .update(complaintData);
          successMessage = 'Complaint updated successfully!';
        }

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save complaint: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.complaintDoc == null
                    ? 'Register New Complaint'
                    : 'Edit Complaint',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _complainerNameController,
                decoration: const InputDecoration(
                  labelText: 'Complainer Name*',
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number*',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedComplainerType,
                      decoration: const InputDecoration(
                        labelText: 'Complainer Type*',
                      ),
                      items: _complainerTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedComplainerType = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Complaint Category*',
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority Level',
                      ),
                      items: _priorities
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPriority = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Assign to Department',
                      ),
                      items: _departments
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDepartment = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _resolutionDateController,
                decoration: const InputDecoration(
                  labelText: 'Expected Resolution Date',
                  hintText: 'MM/DD/YYYY',
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    _resolutionDateController.text = DateFormat(
                      'MM/dd/yyyy',
                    ).format(date);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject*',
                  hintText: 'Brief subject of the complaint...',
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Detailed Description*',
                  hintText: 'Provide detailed description of the complaint...',
                ),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Additional Remarks',
                  hintText: 'Any additional information...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Follow-up required'),
                value: _followUpRequired,
                onChanged: (val) => setState(() => _followUpRequired = val),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveComplaint,
                    child: Text(
                      widget.complaintDoc == null
                          ? 'Register Complaint'
                          : 'Save Changes',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New widget for the Visitor Book Tab
class _VisitorBookTab extends StatefulWidget {
  const _VisitorBookTab();
  @override
  State<_VisitorBookTab> createState() => _VisitorBookTabState();
}

class _VisitorBookTabState extends State<_VisitorBookTab> {
  final List<Map<String, dynamic>> _summaryData = [];

  @override
  void initState() {
    super.initState();
    // Populate summary data here
    _summaryData.addAll([
      {
        'title': 'Total Visitors',
        'icon': Icons.groups_outlined,
        'color': Colors.blue,
      },
      {
        'title': 'Currently In',
        'icon': Icons.login_outlined,
        'color': Colors.green,
      },
      {
        'title': 'Checked Out',
        'icon': Icons.logout_outlined,
        'color': Colors.orange,
      },
      {
        'title': 'Security Alerts',
        'icon': Icons.security_outlined,
        'color': Colors.red,
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('visitors')
              .orderBy('checkInTime', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visitor Records',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  // Visitor List/Table
                  if (docs.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.0),
                        child: Text('No visitors found.'),
                      ),
                    )
                  else
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 12, // Reduced spacing
                          horizontalMargin: 8, // Reduced margins
                          dataRowMinHeight: 32, // Smaller row height
                          dataRowMaxHeight: 40, // Smaller max height
                          headingRowHeight: 36, // Smaller header height
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Visitor ID',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Name',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Company',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Purpose',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Person to Meet',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Transport',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Vehicle No.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Check In',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Check Out',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Actions',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          rows: docs.map((doc) {
                            final visitor = doc.data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    visitor['visitorId'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    visitor['name'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    visitor['company'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    visitor['purpose'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    visitor['personToMeet'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    visitor['transportMode'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    visitor['vehicleNumber'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    visitor['checkInTime'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    visitor['checkOutTime'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        visitor['status'] ?? '',
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      visitor['status'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          _editVisitor(doc);
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          _deleteVisitor(
                                            doc.id,
                                            visitor['name'] ?? '',
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  // Check In New Visitor Button - Moved here from FAB
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                              ),
                              child: const _AddVisitorForm(),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Check In New Visitor'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSmallSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03), // 3% of screen width
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: isSmallScreen ? 20 : 24, color: color),
            SizedBox(height: screenWidth * 0.02), // 2% of screen width
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.01), // 1% of screen width
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: isSmallScreen ? 10 : 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editVisitor(DocumentSnapshot visitorDoc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _AddVisitorForm(visitorDoc: visitorDoc),
        );
      },
    );
  }

  Future<void> _deleteVisitor(String docId, String visitorName) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete the record for "$visitorName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('visitors')
            .doc(docId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visitor record deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting visitor: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'New':
    case 'Checked In':
      return Colors.green;
    case 'Contacted':
      return Colors.blue;
    case 'Enrolled':
    case 'Checked Out':
    case 'In Transit':
      return Colors.orange;
    case 'Delivered':
      return Colors.green;
    case 'Open':
      return Colors.orange;
    case 'In Progress':
      return Colors.blue;
    case 'Pending Collection':
      return Colors
          .orange; // Assuming pending collection is similar to in transit
    default: // For 'Urgent' and other unhandled statuses
      return Colors.grey.shade600;
  }
}

// New widget for the Add Admission Enquiry Form
class _AddAdmissionEnquiryForm extends StatefulWidget {
  final DocumentSnapshot? enquiryDoc;
  const _AddAdmissionEnquiryForm({this.enquiryDoc});

  @override
  State<_AddAdmissionEnquiryForm> createState() =>
      _AddAdmissionEnquiryFormState();
}

class _AddAdmissionEnquiryFormState extends State<_AddAdmissionEnquiryForm> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedSession;
  String? _selectedClass;
  String? _selectedSource;

  // Dummy data for dropdowns
  final List<String> _academicSessions = ['2024-2025', '2025-2026'];
  final List<String> _classes = ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4'];
  final List<String> _sources = [
    'Website',
    'Referral',
    'Walk-in',
    'Advertisement',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.enquiryDoc != null) {
      final data = widget.enquiryDoc!.data() as Map<String, dynamic>;
      _studentNameController.text = data['studentName'] ?? '';
      _fatherNameController.text = data['fatherName'] ?? '';
      _motherNameController.text = data['motherName'] ?? '';
      _phoneController.text = data['fatherPhone'] ?? '';
      _emailController.text = data['email'] ?? '';
      _notesController.text = data['notes'] ?? '';
      _selectedSession = data['academicSession'];
      _selectedClass = data['classSought'];
      _selectedSource = data['source'];
    }
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveEnquiry() async {
    if (_formKey.currentState!.validate()) {
      final enquiryData = {
        'studentName': _studentNameController.text,
        'fatherName': _fatherNameController.text,
        'motherName': _motherNameController.text,
        'fatherPhone': _phoneController.text,
        'email': _emailController.text,
        'classSought': _selectedClass,
        'academicSession': _selectedSession,
        'source': _selectedSource,
        'notes': _notesController.text,
      };

      try {
        final firestore = FirebaseFirestore.instance;
        String successMessage;

        if (widget.enquiryDoc == null) {
          // Creating a new enquiry
          const uuid = Uuid();
          final enquiryNo = 'ENQ-${uuid.v4().substring(0, 6).toUpperCase()}';
          enquiryData['enquiryNo'] = enquiryNo;
          enquiryData['enquiryDate'] = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.now());
          enquiryData['status'] = 'New';

          await firestore.collection('admission_enquiries').add(enquiryData);
          successMessage = 'Enquiry saved successfully!';
        } else {
          // Updating an existing enquiry
          await firestore
              .collection('admission_enquiries')
              .doc(widget.enquiryDoc!.id)
              .update(enquiryData);
          successMessage = 'Enquiry updated successfully!';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Pop and indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save enquiry: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.enquiryDoc == null
                    ? 'New Admission Enquiry'
                    : 'Edit Admission Enquiry',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _studentNameController,
                decoration: const InputDecoration(labelText: 'Student Name*'),
                validator: (value) =>
                    value!.isEmpty ? 'Student name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fatherNameController,
                decoration: const InputDecoration(labelText: 'Father Name*'),
                validator: (value) =>
                    value!.isEmpty ? 'Father name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motherNameController,
                decoration: const InputDecoration(labelText: 'Mother Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number*'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSession,
                decoration: const InputDecoration(
                  labelText: 'Academic Session*',
                ),
                items: _academicSessions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSession = value),
                validator: (value) =>
                    value == null ? 'Please select a session' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: const InputDecoration(labelText: 'Class Sought*'),
                items: _classes
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedClass = value),
                validator: (value) =>
                    value == null ? 'Please select a class' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSource,
                decoration: const InputDecoration(labelText: 'Enquiry Source'),
                items: _sources
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSource = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Any specific requirements or notes...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveEnquiry,
                    child: Text(
                      widget.enquiryDoc == null
                          ? 'Save Enquiry'
                          : 'Save Changes',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New widget for the Add Visitor Form
class _AddVisitorForm extends StatefulWidget {
  final DocumentSnapshot? visitorDoc;
  const _AddVisitorForm({this.visitorDoc});

  @override
  State<_AddVisitorForm> createState() => _AddVisitorFormState();
}

class _AddVisitorFormState extends State<_AddVisitorForm> {
  final _formKey = GlobalKey<FormState>();
  final _visitorNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _personToMeetController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _remarksController = TextEditingController();

  String? _selectedPurpose;
  String? _selectedDepartment;
  String? _selectedTransportMode;
  bool _isVehicleNumberApplicable = false;

  // Dummy data for dropdowns
  final List<String> _purposes = [
    'Meeting',
    'Parent Visit',
    'Delivery',
    'Interview',
    'Other',
  ];
  final List<String> _departments = [
    'Principal\'s Office',
    'Accounts',
    'Admissions',
    'HR',
    'IT',
  ];
  final List<String> _transportModes = [
    'Walk-in',
    'Car',
    'Motorbike',
    'Bicycle',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.visitorDoc != null) {
      final data = widget.visitorDoc!.data() as Map<String, dynamic>;
      _visitorNameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _emailController.text = data['email'] ?? '';
      _companyController.text = data['company'] ?? '';
      _personToMeetController.text = data['personToMeet'] ?? '';
      _vehicleNumberController.text = data['vehicleNumber'] ?? '';
      _remarksController.text = data['remarks'] ?? '';
      _selectedPurpose = data['purpose'];
      _selectedDepartment = data['department'];
      // Use a post-frame callback to ensure the state is set after the build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateVehicleNumberState(data['transportMode']);
      });
    }
  }

  @override
  void dispose() {
    _visitorNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _personToMeetController.dispose();
    _vehicleNumberController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _updateVehicleNumberState(String? mode) {
    setState(() {
      _selectedTransportMode = mode;
      _isVehicleNumberApplicable =
          mode != null && mode != 'Walk-in' && mode != 'Bicycle';
      if (!_isVehicleNumberApplicable) {
        _vehicleNumberController.clear();
      }
    });
  }

  Future<void> _checkInVisitor() async {
    if (_formKey.currentState!.validate()) {
      final visitorData = {
        'name': _visitorNameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'company': _companyController.text,
        'purpose': _selectedPurpose,
        'personToMeet': _personToMeetController.text,
        'department': _selectedDepartment,
        'transportMode': _selectedTransportMode,
        'vehicleNumber': _vehicleNumberController.text,
        'remarks': _remarksController.text,
      };

      try {
        final firestore = FirebaseFirestore.instance;
        String successMessage;

        if (widget.visitorDoc == null) {
          // Creating a new visitor
          const uuid = Uuid();
          final visitorId = 'VIS-${uuid.v4().substring(0, 6).toUpperCase()}';
          visitorData['visitorId'] = visitorId;
          visitorData['checkInTime'] = DateFormat(
            'yyyy-MM-dd HH:mm',
          ).format(DateTime.now());
          visitorData['status'] = 'Checked In';

          await firestore.collection('visitors').add(visitorData);
          successMessage = 'Visitor checked in successfully!';
        } else {
          // Updating an existing visitor
          await firestore
              .collection('visitors')
              .doc(widget.visitorDoc!.id)
              .update(visitorData);
          successMessage = 'Visitor record updated successfully!';
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint('Error saving visitor: $e');
      }
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.visitorDoc == null
                    ? 'Visitor Check In'
                    : 'Edit Visitor Record',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _visitorNameController,
                decoration: const InputDecoration(labelText: 'Visitor Name*'),
                validator: (value) =>
                    value!.isEmpty ? 'Visitor name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number*'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company/Organization',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPurpose,
                decoration: const InputDecoration(
                  labelText: 'Purpose of Visit*',
                ),
                items: _purposes
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedPurpose = value),
                validator: (value) =>
                    value == null ? 'Please select a purpose' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _personToMeetController,
                decoration: const InputDecoration(labelText: 'Person to Meet*'),
                validator: (value) =>
                    value!.isEmpty ? 'This field is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(labelText: 'Department'),
                items: _departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedDepartment = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTransportMode,
                decoration: const InputDecoration(
                  labelText: 'Mode of Transport',
                ),
                items: _transportModes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: _updateVehicleNumberState,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleNumberController,
                decoration: InputDecoration(
                  labelText: 'Vehicle Number Plate',
                  hintText: _isVehicleNumberApplicable
                      ? 'Enter vehicle number'
                      : 'Not applicable',
                ),
                enabled: _isVehicleNumberApplicable,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  hintText: 'Any additional notes...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _checkInVisitor,
                    icon: const Icon(Icons.login),
                    label: Text(
                      widget.visitorDoc == null
                          ? 'Check In Visitor'
                          : 'Save Changes',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
