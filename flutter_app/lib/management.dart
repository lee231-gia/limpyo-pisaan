import 'package:flutter/material.dart';
import 'community.dart';
import 'state.dart';
import 'ui.dart';

class ManagementPage extends StatelessWidget {
  final AppState state;
  final OpenPage open;
  final VoidCallback? back;
  const ManagementPage({
    super.key,
    required this.state,
    required this.open,
    this.back,
  });

  @override
  Widget build(BuildContext context) {
    final pending = state.reports
        .where((report) => report.status == 'Pending')
        .length;
    final active = state.reports
        .where((report) => report.status == 'In Progress')
        .length;
    return PageBody(
      children: [
        PageHeading(
          'Barangay Management',
          subtitle: 'Review concerns and keep residents informed.',
          back: back,
        ),
        const Notice(
          'Management actions are stored on this device in the frontend build. They do not notify other devices yet.',
          icon: Icons.devices_outlined,
        ),
        Row(
          children: [
            Expanded(
              child: _CountCard(value: '$pending', label: 'Pending'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CountCard(value: '$active', label: 'In progress'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CountCard(
                value: '${state.reports.length}',
                label: 'All reports',
              ),
            ),
          ],
        ),
        const SectionTitle('Management tools'),
        MenuCard(
          icon: Icons.assignment_turned_in_outlined,
          title: 'Report inbox',
          subtitle: pending == 1
              ? '1 report needs review'
              : '$pending reports need review',
          onTap: () => open('management-reports'),
        ),
        MenuCard(
          icon: Icons.campaign_outlined,
          title: 'Announcements',
          subtitle: 'Post community notices and clean-up calls',
          onTap: () => open('manage-announcements'),
        ),
        MenuCard(
          icon: Icons.photo_library_outlined,
          title: 'Community showcase',
          subtitle: 'Post good examples, clean-up progress, or concerns',
          onTap: () => open('updates'),
        ),
        MenuCard(
          icon: Icons.menu_book_outlined,
          title: 'Waste guide',
          subtitle: 'Add practical disposal tips for residents',
          onTap: () => open('manage-guides'),
        ),
        MenuCard(
          icon: Icons.location_on_outlined,
          title: 'Collection and drop-off',
          subtitle: 'Set schedules, locations, and accepted waste',
          onTap: () => open('manage-services'),
        ),
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  final String value, label;
  const _CountCard({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Surface(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    child: Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        space(5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, fontSize: 9),
        ),
      ],
    ),
  );
}

class ManagementReportsPage extends StatefulWidget {
  final AppState state;
  final OpenPage open;
  final VoidCallback back;
  const ManagementReportsPage({
    super.key,
    required this.state,
    required this.open,
    required this.back,
  });
  @override
  State<ManagementReportsPage> createState() => _ManagementReportsPageState();
}

class _ManagementReportsPageState extends State<ManagementReportsPage> {
  String filter = 'Pending';
  @override
  Widget build(BuildContext context) {
    final reports = widget.state.reports
        .where((report) => filter == 'All' || report.status == filter)
        .toList();
    return PageBody(
      children: [
        PageHeading(
          'Report inbox',
          subtitle: 'Review and respond with care.',
          back: widget.back,
        ),
        Wrap(
          spacing: 7,
          children: [
            for (final value in ['Pending', 'In Progress', 'Resolved', 'All'])
              ChoiceChip(
                selected: filter == value,
                showCheckmark: false,
                label: Text(value, style: const TextStyle(fontSize: 10)),
                onSelected: (_) => setState(() => filter = value),
              ),
          ],
        ),
        space(20),
        if (reports.isEmpty)
          const Surface(
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, color: muted, size: 50),
                SizedBox(height: 16),
                Text(
                  'Nothing here yet',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Reports submitted on this device will appear in the inbox.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
        for (final report in reports)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              onTap: () => widget.open('manage-report:${report.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tag(report.status),
                    space(15),
                    Text(
                      report.type,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    space(8),
                    Text(
                      report.location,
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                    space(16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${report.id} · ${report.date}',
                            style: const TextStyle(color: muted, fontSize: 10),
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: green, size: 17),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ManageReportPage extends StatefulWidget {
  final AppState state;
  final WasteReport report;
  final VoidCallback back;
  final OpenPage open;
  const ManageReportPage({
    super.key,
    required this.state,
    required this.report,
    required this.back,
    required this.open,
  });
  @override
  State<ManageReportPage> createState() => _ManageReportPageState();
}

class _ManageReportPageState extends State<ManageReportPage> {
  late String status;
  late final TextEditingController response;
  bool saving = false;
  @override
  void initState() {
    super.initState();
    status = widget.report.status;
    response = TextEditingController(
      text: widget.report.officialResponse ?? '',
    );
  }

  @override
  void dispose() {
    response.dispose();
    super.dispose();
  }

  Future<void> save({bool publish = false}) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      await widget.state.updateReport(
        widget.report.id,
        status: status,
        response: response.text,
      );
      if (publish) {
        await widget.state.addAnnouncement(
          title: 'Community action needed: ${widget.report.type}',
          body:
              'We received a concern near ${widget.report.location}. Let’s work together to keep this shared space clean and safe.',
          category: 'COMMUNITY ACTION',
        );
      }
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle_outline, color: green),
            title: Text(publish ? 'Update published' : 'Report update saved'),
            content: Text(
              publish
                  ? 'The resident response was saved and a community notice was posted.'
                  : 'The report status and resident response are now saved.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to inbox'),
              ),
            ],
          ),
        );
        if (context.mounted) widget.back();
      }
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Could not save the management update.');
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      PageHeading(
        'Review report',
        subtitle: widget.report.id,
        back: widget.back,
      ),
      Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tag(widget.report.status),
            space(18),
            detail('Issue', widget.report.type),
            detail('Location', widget.report.location),
            detail('Resident description', widget.report.description),
          ],
        ),
      ),
      const SectionTitle('Management response'),
      const Text(
        'Status',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      space(8),
      DropdownButtonFormField<String>(
        initialValue: status,
        items: ['Pending', 'In Progress', 'Resolved']
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: saving
            ? null
            : (value) => setState(() => status = value ?? status),
      ),
      space(18),
      TextFormField(
        controller: response,
        enabled: !saving,
        maxLines: 4,
        maxLength: 500,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Response to resident',
          hintText: 'e.g. Thank you. Our team will check the area.',
        ),
      ),
      space(14),
      primaryButton(
        saving ? 'Saving…' : 'Save update',
        saving ? null : () => save(),
        icon: Icons.save_outlined,
      ),
      space(12),
      secondaryButton(
        'Save and publish community notice',
        saving ? null : () => save(publish: true),
      ),
    ],
  );
}

class ManageAnnouncementsPage extends StatefulWidget {
  final AppState state;
  final VoidCallback back;
  const ManageAnnouncementsPage({
    super.key,
    required this.state,
    required this.back,
  });
  @override
  State<ManageAnnouncementsPage> createState() =>
      _ManageAnnouncementsPageState();
}

class _ManageAnnouncementsPageState extends State<ManageAnnouncementsPage> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(), body = TextEditingController();
  String category = 'BARANGAY NOTICE';
  bool saving = false;
  bool published = false;
  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  Future<void> publish() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await widget.state.addAnnouncement(
        title: title.text,
        body: body.text,
        category: category,
      );
      title.clear();
      body.clear();
      if (mounted) setState(() => published = true);
    } catch (_) {
      if (mounted) showMessage(context, 'Could not publish the announcement.');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      PageHeading(
        'Announcements',
        subtitle: 'Share clear updates with residents.',
        back: widget.back,
      ),
      Surface(
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New announcement',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              space(16),
              DropdownButtonFormField<String>(
                initialValue: category,
                items:
                    ['BARANGAY NOTICE', 'COMMUNITY ACTION', 'COLLECTION UPDATE']
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: saving
                    ? null
                    : (value) => setState(() => category = value ?? category),
              ),
              space(14),
              TextFormField(
                controller: title,
                enabled: !saving,
                maxLength: 120,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (value) =>
                    value?.trim().isNotEmpty == true ? null : 'Enter a title.',
              ),
              space(12),
              TextFormField(
                controller: body,
                enabled: !saving,
                maxLines: 5,
                maxLength: 1200,
                decoration: const InputDecoration(labelText: 'Message *'),
                validator: (value) => value?.trim().isNotEmpty == true
                    ? null
                    : 'Enter a message.',
              ),
              primaryButton(
                saving ? 'Publishing…' : 'Publish announcement',
                saving ? null : publish,
                icon: Icons.campaign_outlined,
              ),
            ],
          ),
        ),
      ),
      if (published) ...[
        space(16),
        const Notice(
          'Announcement published. Residents can now read it in Community Updates on this device.',
          icon: Icons.check_circle_outline,
        ),
      ],
      if (widget.state.announcements.isNotEmpty)
        const SectionTitle('Published on this device'),
      for (final entry in widget.state.announcements)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tag(entry.category),
                space(10),
                Text(
                  entry.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                space(8),
                Text(
                  entry.date,
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class ManageGuidesPage extends StatefulWidget {
  final AppState state;
  final VoidCallback back;
  const ManageGuidesPage({super.key, required this.state, required this.back});
  @override
  State<ManageGuidesPage> createState() => _ManageGuidesPageState();
}

class _ManageGuidesPageState extends State<ManageGuidesPage> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController();
  final body = TextEditingController();
  bool saving = false;
  bool published = false;
  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  Future<void> publish() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await widget.state.addGuide(title: title.text, body: body.text);
      title.clear();
      body.clear();
      if (mounted) setState(() => published = true);
    } catch (_) {
      if (mounted) showMessage(context, 'Could not publish the guide tip.');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      PageHeading(
        'Waste guide',
        subtitle: 'Add clear, practical tips for residents.',
        back: widget.back,
      ),
      Surface(
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New guide tip',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              space(16),
              TextFormField(
                controller: title,
                enabled: !saving,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Tip title *',
                  hintText: 'e.g. Keep recyclables clean and dry',
                ),
                validator: (value) =>
                    value?.trim().isNotEmpty == true ? null : 'Enter a title.',
              ),
              space(12),
              TextFormField(
                controller: body,
                enabled: !saving,
                maxLines: 5,
                maxLength: 700,
                decoration: const InputDecoration(
                  labelText: 'Guide details *',
                  hintText:
                      'Explain what residents should do and why it helps.',
                ),
                validator: (value) => value?.trim().isNotEmpty == true
                    ? null
                    : 'Enter the guide details.',
              ),
              primaryButton(
                saving ? 'Publishing…' : 'Publish guide tip',
                saving ? null : publish,
                icon: Icons.menu_book_outlined,
              ),
            ],
          ),
        ),
      ),
      if (published) ...[
        space(16),
        const Notice(
          'Guide tip published. Residents can now read it in the Waste Guide on this device.',
          icon: Icons.check_circle_outline,
        ),
      ],
      if (widget.state.guides.isNotEmpty)
        const SectionTitle('Published guide tips'),
      for (final guide in widget.state.guides)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guide.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                space(8),
                Text(
                  guide.date,
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class ManageServicesPage extends StatefulWidget {
  final AppState state;
  final VoidCallback back;
  const ManageServicesPage({
    super.key,
    required this.state,
    required this.back,
  });
  @override
  State<ManageServicesPage> createState() => _ManageServicesPageState();
}

class _ManageServicesPageState extends State<ManageServicesPage> {
  final form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> fields;
  late double pinX, pinY;
  bool saving = false;
  bool saved = false;
  @override
  void initState() {
    super.initState();
    final s = widget.state.services;
    pinX = s.dropoffPinX;
    pinY = s.dropoffPinY;
    fields = {
      'Collection day': TextEditingController(text: s.collectionDay),
      'Collection time': TextEditingController(text: s.collectionTime),
      'Service area': TextEditingController(text: s.serviceArea),
      'Update window': TextEditingController(text: s.updateWindow),
      'Drop-off name': TextEditingController(text: s.dropoffName),
      'Landmark': TextEditingController(text: s.dropoffLandmark),
      'Accepted waste': TextEditingController(text: s.acceptedWaste),
      'Operating hours': TextEditingController(text: s.operatingHours),
    };
  }

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await widget.state.updateServices(
        ServiceSettings(
          collectionDay: fields['Collection day']!.text.trim(),
          collectionTime: fields['Collection time']!.text.trim(),
          serviceArea: fields['Service area']!.text.trim(),
          updateWindow: fields['Update window']!.text.trim(),
          dropoffName: fields['Drop-off name']!.text.trim(),
          dropoffLandmark: fields['Landmark']!.text.trim(),
          acceptedWaste: fields['Accepted waste']!.text.trim(),
          operatingHours: fields['Operating hours']!.text.trim(),
          dropoffPinX: pinX,
          dropoffPinY: pinY,
        ),
      );
      if (mounted) setState(() => saved = true);
    } catch (_) {
      if (mounted) showMessage(context, 'Could not save service details.');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      PageHeading(
        'Collection and drop-off',
        subtitle: 'Set the details residents see.',
        back: widget.back,
      ),
      Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Collection schedule'),
            for (final label in [
              'Collection day',
              'Collection time',
              'Service area',
              'Update window',
            ])
              _field(label),
            const SectionTitle('Drop-off location'),
            CommunityMap(
              pinX: pinX,
              pinY: pinY,
              editable: true,
              onPinChanged: (point) => setState(() {
                pinX = point.dx;
                pinY = point.dy;
                saved = false;
              }),
            ),
            space(10),
            const Text(
              'Tap the map to pinpoint the drop-off location residents will see.',
              style: TextStyle(color: muted, fontSize: 11, height: 1.6),
            ),
            if (saved) ...[
              space(16),
              const Notice(
                'Service details and the drop-off pin have been saved. Residents will see the updated information on this device.',
                icon: Icons.check_circle_outline,
              ),
            ],
            space(16),
            for (final label in [
              'Drop-off name',
              'Landmark',
              'Accepted waste',
              'Operating hours',
            ])
              _field(label),
            primaryButton(
              saving ? 'Saving…' : 'Save service details',
              saving ? null : save,
              icon: Icons.save_outlined,
            ),
          ],
        ),
      ),
    ],
  );
  Widget _field(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: fields[label],
      enabled: !saving,
      maxLength: 140,
      decoration: InputDecoration(labelText: '$label *'),
      validator: (value) =>
          value?.trim().isNotEmpty == true ? null : 'Enter $label.',
    ),
  );
}
