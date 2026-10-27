import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'photo_storage.dart';
import 'state.dart';
import 'ui.dart';
import 'photo_picker.dart';

class ReportFormPage extends StatefulWidget {
  final ReportDraft draft;
  final VoidCallback review;
  const ReportFormPage({super.key, required this.draft, required this.review});
  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final form = GlobalKey<FormState>();
  late final TextEditingController location, description, customIssue;
  bool otherIssue = false;
  bool tried = false, photoBusy = false;
  @override
  void initState() {
    super.initState();
    otherIssue =
        widget.draft.type.isNotEmpty &&
        (!issueTypes.contains(widget.draft.type) ||
            widget.draft.type == issueTypes.last);
    customIssue = TextEditingController(
      text: otherIssue && widget.draft.type != issueTypes.last
          ? widget.draft.type
          : '',
    );
    if (otherIssue) widget.draft.type = customIssue.text;
    location = TextEditingController(text: widget.draft.location);
    description = TextEditingController(text: widget.draft.description);
    recoverPhoto();
  }

  @override
  void dispose() {
    customIssue.dispose();
    location.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> recoverPhoto() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final lost = await OwnedPhotoPicker.recover('report');
      if (lost != null) await savePhoto(lost);
    } catch (_) {
      /* A canceled or unavailable picker leaves the optional photo empty. */
    }
  }

  Future<void> savePhoto(XFile photo) async {
    final saved = await storePhoto(photo, 'report');
    if (!mounted) {
      await deletePhoto(saved);
      return;
    }
    final old = widget.draft.photo;
    setState(() => widget.draft.photo = saved);
    await deletePhoto(old);
  }

  Future<void> pickPhoto(ImageSource source) async {
    if (photoBusy) return;
    setState(() => photoBusy = true);
    try {
      final photo = await OwnedPhotoPicker.pick('report', source);
      if (photo != null) await savePhoto(photo);
    } catch (_) {
      if (mounted) {
        showMessage(
          context,
          'The photo could not be opened. Try the gallery or check camera access.',
        );
      }
    } finally {
      if (mounted) setState(() => photoBusy = false);
    }
  }

  Future<void> chooseIssue() async {
    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: cream,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose issue type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              space(10),
              const Text(
                'Select the concern that best matches your report.',
                style: TextStyle(fontSize: 12, color: muted),
              ),
              space(17),
              for (final type in issueTypes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      title: Text(type, style: const TextStyle(fontSize: 13)),
                      trailing: Icon(
                        widget.draft.type == type
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 20,
                        color: widget.draft.type == type ? green : muted,
                      ),
                      onTap: () => Navigator.pop(context, type),
                    ),
                  ),
                ),
              space(5),
              secondaryButton('Cancel', () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
    if (value != null && mounted) {
      setState(() {
        otherIssue = value == issueTypes.last;
        widget.draft.type = otherIssue ? customIssue.text.trim() : value;
      });
    }
  }

  void review() {
    FocusScope.of(context).unfocus();
    widget.draft.location = location.text;
    widget.draft.description = description.text;
    setState(() => tried = true);
    final formValid = form.currentState!.validate();
    if (formValid && widget.draft.validate().isEmpty) widget.review();
  }

  Widget label(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      value,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const PageHeading(
        'Report an Issue',
        subtitle: 'A small report can help us see what needs care.',
      ),
      const Notice(privacyText, icon: Icons.shield_outlined),
      if (tried && widget.draft.validate().isNotEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 18),
          child: Text(
            'Please check the required fields below.',
            style: TextStyle(color: Color(0xFFAC4943), fontSize: 12),
          ),
        ),
      Form(
        key: form,
        autovalidateMode: tried
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label('Issue type *'),
            Semantics(
              button: true,
              label: 'Choose issue type',
              child: InkWell(
                onTap: chooseIssue,
                borderRadius: BorderRadius.circular(11),
                child: InputDecorator(
                  decoration: InputDecoration(
                    errorText: tried && !otherIssue && widget.draft.type.isEmpty
                        ? 'Choose an issue type.'
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherIssue
                              ? issueTypes.last
                              : widget.draft.type.isEmpty
                              ? 'Select an issue type'
                              : widget.draft.type,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.draft.type.isEmpty ? muted : ink,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (otherIssue) ...[
              space(16),
              TextFormField(
                controller: customIssue,
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Specify issue *',
                  hintText: 'e.g. Broken glass on pathway',
                ),
                onChanged: (value) => widget.draft.type = value.trim(),
                validator: (value) => value?.trim().isNotEmpty == true
                    ? null
                    : 'Enter your issue type.',
              ),
            ],
            space(23),
            label('Location or nearby landmark *'),
            TextFormField(
              controller: location,
              maxLength: 160,
              onChanged: (value) => widget.draft.location = value,
              validator: (value) => value?.trim().isNotEmpty == true
                  ? null
                  : 'Enter a location or nearby landmark.',
              decoration: const InputDecoration(
                hintText: 'Where is the issue?',
                counterText: '',
              ),
            ),
            space(7),
            Wrap(
              spacing: 6,
              children: [
                for (final suggestion in [
                  'Near the store',
                  'Canal by the road',
                  'Public gathering area',
                ])
                  ActionChip(
                    label: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 9),
                    ),
                    visualDensity: VisualDensity.compact,
                    side: const BorderSide(color: line),
                    backgroundColor: pale,
                    onPressed: () {
                      location.text = '$suggestion, Purok 3';
                      widget.draft.location = location.text;
                    },
                  ),
              ],
            ),
            space(18),
            label('Description *'),
            TextFormField(
              controller: description,
              maxLines: 4,
              maxLength: 1500,
              onChanged: (value) => widget.draft.description = value,
              validator: (value) => value?.trim().isNotEmpty == true
                  ? null
                  : 'Describe the waste-related concern.',
              decoration: const InputDecoration(
                hintText: 'Tell us what happened and what needs attention.',
                counterText: '',
              ),
            ),
            space(7),
            const Text(
              'A brief description is enough. Avoid personal or sensitive details.',
              style: TextStyle(fontSize: 10, color: muted, height: 1.6),
            ),
            space(23),
            Surface(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Photo (optional)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  space(7),
                  Text(
                    photoBusy
                        ? 'Preparing photo…'
                        : widget.draft.photo == null
                        ? 'Add a photo to show the concern.'
                        : 'Photo attached',
                    style: const TextStyle(color: muted, fontSize: 11),
                  ),
                  space(12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: photoBusy
                              ? null
                              : () => pickPhoto(ImageSource.gallery),
                          icon: const Icon(
                            Icons.file_upload_outlined,
                            size: 18,
                          ),
                          label: const Text(
                            'Upload',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: photoBusy
                              ? null
                              : () => pickPhoto(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: const Text(
                            'Camera',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.draft.photo != null) ...[
                    space(12),
                    localPhoto(widget.draft.photo),
                    TextButton(
                      onPressed: () =>
                          setState(() => widget.draft.photo = null),
                      child: const Text('Remove photo'),
                    ),
                  ],
                ],
              ),
            ),
            space(24),
            primaryButton(
              'Review Report',
              photoBusy ? null : review,
              icon: Icons.arrow_forward,
            ),
          ],
        ),
      ),
    ],
  );
}

class ReportSummary extends StatelessWidget {
  final String type, location, description;
  final String? photo;
  const ReportSummary({
    super.key,
    required this.type,
    required this.location,
    required this.description,
    this.photo,
  });
  @override
  Widget build(BuildContext context) => Surface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Tag('REPORT DETAILS'),
        space(24),
        detail('Issue type', type),
        detail('Location / landmark', location),
        detail('Description', description),
        localPhoto(photo),
      ],
    ),
  );
}

class ReviewPage extends StatefulWidget {
  final AppState state;
  final ReportDraft draft;
  final VoidCallback back;
  final ValueChanged<WasteReport> onSubmitted;
  final ValueChanged<bool> onSaving;
  const ReviewPage({
    super.key,
    required this.state,
    required this.draft,
    required this.back,
    required this.onSubmitted,
    required this.onSaving,
  });
  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool saving = false;
  Future<void> submit() async {
    if (saving) return;
    setState(() => saving = true);
    widget.onSaving(true);
    try {
      final report = await widget.state.submitReport(widget.draft);
      if (mounted) widget.onSubmitted(report);
    } catch (_) {
      if (mounted) {
        showMessage(
          context,
          'The report could not be saved. Your draft is still available; please try again.',
        );
      }
    } finally {
      if (mounted) {
        widget.onSaving(false);
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      PageHeading(
        'Review Report',
        subtitle: 'Take a moment to check the details.',
        back: saving ? null : widget.back,
      ),
      const Notice(privacyText, icon: Icons.shield_outlined),
      ReportSummary(
        type: widget.draft.type,
        location: widget.draft.location,
        description: widget.draft.description,
        photo: widget.draft.photo,
      ),
      space(22),
      const Text(
        'Check the issue, location, and description before saving your report.',
        style: TextStyle(fontSize: 12, color: muted, height: 1.8),
      ),
      space(22),
      primaryButton(
        saving ? 'Saving…' : 'Save Report',
        saving ? null : submit,
        icon: Icons.send_outlined,
      ),
      space(12),
      secondaryButton('Edit Report', saving ? null : widget.back),
    ],
  );
}

class ReportSuccessPage extends StatelessWidget {
  final WasteReport? report;
  final OpenPage open;
  const ReportSuccessPage({super.key, this.report, required this.open});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      space(15),
      const Center(
        child: CircleAvatar(
          radius: 49,
          backgroundColor: pale,
          child: CircleAvatar(
            radius: 36,
            backgroundColor: green,
            child: Icon(Icons.check, size: 38, color: Colors.white),
          ),
        ),
      ),
      space(30),
      Center(child: eyebrow('THANK YOU FOR CARING')),
      space(20),
      Text(
        'Report saved\nsuccessfully!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      space(16),
      const Text(
        'Your small step helps tell the story\nof a cleaner community.',
        textAlign: TextAlign.center,
        style: TextStyle(color: muted, fontSize: 13, height: 1.8),
      ),
      space(30),
      Surface(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              eyebrow('REPORT REFERENCE'),
              space(13),
              Text(
                report?.id ?? 'LP-001',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              space(12),
              const Text(
                'Saved to My Reports',
                style: TextStyle(color: muted, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
      space(22),
      const Notice(
        'Your report has been saved. You can find its details in My Reports.',
        icon: Icons.shield_outlined,
      ),
      primaryButton(
        'View My Reports',
        () => open('reports'),
        icon: Icons.arrow_forward,
      ),
      space(12),
      secondaryButton('Back to Home', () => open('home')),
    ],
  );
}

class ReportsPage extends StatefulWidget {
  final AppState state;
  final OpenPage open;
  final VoidCallback back;
  const ReportsPage({
    super.key,
    required this.state,
    required this.open,
    required this.back,
  });
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String filter = 'All';
  @override
  Widget build(BuildContext context) {
    final reports = widget.state.reports
        .where((report) => filter == 'All' || report.status == filter)
        .toList();
    return PageBody(
      children: [
        PageHeading(
          'My Reports',
          subtitle: 'Your concerns, kept on this device.',
          back: widget.back,
        ),
        const Notice(privacyText, icon: Icons.shield_outlined),
        Wrap(
          spacing: 7,
          runSpacing: 3,
          children: [
            for (final value in ['All', 'Pending', 'In Progress', 'Resolved'])
              ChoiceChip(
                selected: filter == value,
                showCheckmark: false,
                label: Text(value, style: const TextStyle(fontSize: 10)),
                onSelected: (_) => setState(() => filter = value),
              ),
          ],
        ),
        space(22),
        if (reports.isEmpty)
          Surface(
            child: Column(
              children: [
                const Icon(Icons.edit_note_outlined, size: 55, color: muted),
                space(20),
                Text(
                  'No reports yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                space(12),
                const Text(
                  'Your reports will appear here after you save them.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                space(22),
                primaryButton('Report an Issue', () => widget.open('report')),
              ],
            ),
          ),
        for (final report in reports)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: InkWell(
              onTap: () => widget.open('details:${report.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Tag(
                          report.status,
                          color: report.status == 'Pending'
                              ? const Color(0xFFF4F0DA)
                              : pale,
                        ),
                        Text(
                          report.sample ? 'Report status' : 'Report status',
                          style: const TextStyle(color: muted, fontSize: 9),
                        ),
                      ],
                    ),
                    space(18),
                    Text(
                      report.type,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    space(10),
                    Text(
                      report.location,
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                    space(18),
                    const Divider(),
                    space(8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${report.date} · ${report.id}',
                            style: const TextStyle(fontSize: 10, color: muted),
                          ),
                        ),
                        const Icon(Icons.arrow_forward, size: 17, color: green),
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

class ReportDetailsPage extends StatelessWidget {
  final WasteReport report;
  final VoidCallback back;
  const ReportDetailsPage({
    super.key,
    required this.report,
    required this.back,
  });
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      PageHeading('Report details', back: back),
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 10,
        spacing: 20,
        children: [
          Text(report.id, style: Theme.of(context).textTheme.titleLarge),
          Tag(report.status),
        ],
      ),
      space(10),
      Text(report.date, style: const TextStyle(color: muted, fontSize: 11)),
      space(22),
      const Notice(privacyText, icon: Icons.shield_outlined),
      ReportSummary(
        type: report.type,
        location: report.location,
        description: report.description,
        photo: report.photo,
      ),
      const SectionTitle('Report history'),
      Surface(
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined, color: green),
              title: Text(report.status, style: const TextStyle(fontSize: 13)),
              subtitle: Text(
                report.date,
                style: const TextStyle(fontSize: 11, color: muted),
              ),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle_outline, color: green),
              title: Text('Report saved', style: TextStyle(fontSize: 13)),
              subtitle: Text(
                'Available in My Reports.',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
