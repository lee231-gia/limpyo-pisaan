import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'photo_storage.dart';
import 'state.dart';
import 'ui.dart';
import 'photo_picker.dart';

class AddShowcasePage extends StatefulWidget {
  final AppState state;
  const AddShowcasePage({super.key, required this.state});
  @override
  State<AddShowcasePage> createState() => _AddShowcasePageState();
}

class _AddShowcasePageState extends State<AddShowcasePage> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(), story = TextEditingController();
  String? photo;
  bool busy = false, saving = false, saved = false;
  @override
  void initState() {
    super.initState();
    recoverPhoto();
  }

  Future<void> recoverPhoto() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final lost = await OwnedPhotoPicker.recover('showcase');
      if (lost != null) await keepPhoto(lost);
    } catch (_) {}
  }

  Future<void> keepPhoto(XFile picked) async {
    final saved = await storePhoto(picked, 'showcase');
    if (!mounted) {
      await deletePhoto(saved);
      return;
    }
    final old = photo;
    setState(() => photo = saved);
    await deletePhoto(old);
  }

  Future<void> pick(ImageSource source) async {
    if (busy || saving) return;
    setState(() => busy = true);
    try {
      final file = await OwnedPhotoPicker.pick('showcase', source);
      if (file != null) await keepPhoto(file);
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Could not open the photo. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    if (saving || busy || !form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => saving = true);
    try {
      await widget.state.addShowcase(title.text, story.text, photo);
      saved = true;
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Could not save your showcase. Please try again.');
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    title.dispose();
    story.dispose();
    if (!saved && photo != null) {
      deletePhoto(photo);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving && !busy,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Add showcase'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: saving || busy ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: PageBody(
              children: [
                const PageHeading(
                  'Share a little community care',
                  subtitle:
                      'A good habit, a shared concern, or a small achievement.',
                ),
                Form(
                  key: form,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: title,
                        enabled: !saving,
                        maxLength: 120,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          hintText: 'Give your story a title',
                        ),
                        validator: (v) => v?.trim().isNotEmpty == true
                            ? null
                            : 'Enter a title.',
                      ),
                      space(18),
                      TextFormField(
                        controller: story,
                        enabled: !saving,
                        maxLength: 2000,
                        minLines: 4,
                        maxLines: 8,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Your story *',
                          hintText: 'Unsay inyong ikapaambit?',
                        ),
                        validator: (v) => v?.trim().isNotEmpty == true
                            ? null
                            : 'Write your story.',
                      ),
                    ],
                  ),
                ),
                space(18),
                const Text(
                  'Photo (optional)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                space(12),
                if (photo != null) ...[
                  localPhoto(photo),
                  TextButton.icon(
                    onPressed: saving || busy
                        ? null
                        : () {
                            final old = photo!;
                            setState(() => photo = null);
                            deletePhoto(old);
                          },
                    icon: const Icon(Icons.close),
                    label: const Text('Remove photo'),
                  ),
                ],
                if (busy) const Center(child: CircularProgressIndicator()),
                Wrap(
                  spacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: saving || busy
                          ? null
                          : () => pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                    OutlinedButton.icon(
                      onPressed: saving || busy
                          ? null
                          : () => pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Camera'),
                    ),
                  ],
                ),
                space(22),
                primaryButton(
                  saving ? 'Saving…' : 'Save showcase',
                  saving || busy ? null : save,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class ResidentShowcasePage extends StatelessWidget {
  final ShowcaseEntry entry;
  final VoidCallback back;
  const ResidentShowcasePage({
    super.key,
    required this.entry,
    required this.back,
  });
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      PageHeading('Community showcase', back: back),
      const Tag('COMMUNITY STORY'),
      space(18),
      Text(entry.title, style: Theme.of(context).textTheme.titleLarge),
      space(12),
      Text(
        '${entry.author} · ${entry.date}',
        style: const TextStyle(color: muted, fontSize: 11),
      ),
      space(24),
      if (entry.photo != null) ...[
        localPhoto(entry.photo, height: 250),
        space(24),
      ],
      Text(entry.body, style: const TextStyle(height: 1.8, fontSize: 14)),
    ],
  );
}
