import 'photo_storage.dart';
import 'package:flutter/material.dart';

const cream = Color(0xFFF8F8F0),
    green = Color(0xFF24583F),
    ink = Color(0xFF243B2D),
    muted = Color(0xFF758071),
    pale = Color(0xFFEAF0E2),
    line = Color(0xFFE4E8DB);
typedef OpenPage = void Function(String page);

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: green,
    primary: green,
    surface: cream,
    error: const Color(0xFFAC4943),
  ),
  scaffoldBackgroundColor: cream,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: ink, fontSize: 14, height: 1.5),
    bodySmall: TextStyle(color: muted, fontSize: 12, height: 1.5),
    titleLarge: TextStyle(
      color: ink,
      fontSize: 23,
      fontWeight: FontWeight.w800,
      letterSpacing: -.6,
    ),
    titleMedium: TextStyle(
      color: ink,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      color: ink,
      fontSize: 30,
      fontWeight: FontWeight.w800,
      height: 1.2,
      letterSpacing: -.8,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: cream,
    surfaceTintColor: Colors.transparent,
    foregroundColor: green,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
    hintStyle: TextStyle(color: muted.withValues(alpha: .7), fontSize: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: green, width: 1.5),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: green,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: green,
      backgroundColor: Colors.white,
      minimumSize: const Size(0, 50),
      side: const BorderSide(color: line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
    ),
  ),
  dividerTheme: const DividerThemeData(color: line, thickness: 1),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    indicatorColor: pale,
    height: 72,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        fontSize: 10,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w700
            : FontWeight.w400,
        color: states.contains(WidgetState.selected) ? green : muted,
      ),
    ),
  ),
);

class Brand extends StatelessWidget {
  final double size;
  const Brand({super.key, this.size = 38});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.asset('assets/logo.png', width: size, height: size),
      ),
      const SizedBox(width: 10),
      const Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Limpyo Pisaan',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: -.4,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'OUR PLACE. OUR SHARED CARE.',
              style: TextStyle(fontSize: 6.5, letterSpacing: 1, color: muted),
            ),
          ],
        ),
      ),
    ],
  );
}

class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
    children: children,
  );
}

class PageHeading extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback? back;
  const PageHeading(this.title, {super.key, this.subtitle = '', this.back});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (back != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: back,
              icon: const Icon(Icons.arrow_back, size: 20),
              tooltip: 'Back',
              visualDensity: VisualDensity.compact,
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class Surface extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = Colors.white,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: line),
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}

class Notice extends StatelessWidget {
  final String text;
  final IconData icon;
  const Notice(this.text, {super.key, this.icon = Icons.info_outline});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: pale,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: green.withValues(alpha: .65)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              height: 1.6,
              color: green.withValues(alpha: .8),
            ),
          ),
        ),
      ],
    ),
  );
}

const privacyText =
    'Your reports stay in My Reports and are not posted to Community Updates.';

class Tag extends StatelessWidget {
  final String text;
  final Color? color;
  const Tag(this.text, {super.key, this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color ?? pale,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: green,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;
  const SectionTitle(this.title, {super.key, this.action});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 25, bottom: 15),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ?action,
      ],
    ),
  );
}

class IconTile extends StatelessWidget {
  final IconData icon;
  const IconTile(this.icon, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: pale,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Icon(icon, color: const Color(0xFF78936A), size: 23),
  );
}

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool danger;
  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = '',
    required this.onTap,
    this.danger = false,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: line),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              IconTile(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: danger ? const Color(0xFFAC4943) : ink,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 11,
                            height: 1.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 18, color: muted),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget primaryButton(
  String label,
  VoidCallback? onPressed, {
  IconData? icon,
}) => SizedBox(
  width: double.infinity,
  child: FilledButton(
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        if (icon != null) ...[const SizedBox(width: 10), Icon(icon, size: 17)],
      ],
    ),
  ),
);
Widget secondaryButton(String label, VoidCallback? onPressed) => SizedBox(
  width: double.infinity,
  child: OutlinedButton(onPressed: onPressed, child: Text(label)),
);
Widget space([double height = 16]) => SizedBox(height: height);
Widget eyebrow(String text) => Text(
  text,
  style: const TextStyle(
    color: Color(0xFF78936A),
    fontSize: 9,
    letterSpacing: 1.3,
    fontWeight: FontWeight.w600,
  ),
);
Widget detail(String label, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: muted, fontSize: 10)),
      space(6),
      Text(value, style: const TextStyle(fontSize: 13, height: 1.65)),
    ],
  ),
);
Widget localPhoto(String? path, {double height = 190}) => path == null
    ? const Text(
        'No photo attached',
        style: TextStyle(color: muted, fontSize: 11),
      )
    : ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image(
          image: photoProvider(path),
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Padding(
            padding: EdgeInsets.all(15),
            child: Text('This photo is no longer available on the device.'),
          ),
        ),
      );
void showMessage(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
