import 'package:flutter/material.dart';
import 'state.dart';
import 'ui.dart';
import 'community_photos.dart';

class ProfilePage extends StatelessWidget {
  final AppState state;
  final OpenPage open;
  const ProfilePage({super.key, required this.state, required this.open});
  Future<void> logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cream,
        icon: const Icon(Icons.logout, color: green),
        title: const Text('Log out of Limpyo Pisaan?'),
        content: const Text(
          'You’ll return to the login screen. Your reports will be kept for your next visit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Log Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await state.logout();
      } catch (_) {
        if (context.mounted) {
          showMessage(context, 'Could not log out. Please try again.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const PageHeading(
        'Your Profile',
        subtitle: 'Your little corner of the community.',
      ),
      space(10),
      Center(
        child: CircleAvatar(
          radius: 43,
          backgroundColor: pale,
          child: Text(
            state.initials,
            style: const TextStyle(
              color: green,
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      space(22),
      Text(
        state.name,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      space(8),
      Text(
        state.email,
        textAlign: TextAlign.center,
        style: const TextStyle(color: muted, fontSize: 12),
      ),
      space(14),
      const Center(child: Tag('RESIDENT · PUROK 3')),
      space(12),
      const Text(
        'Purok 3 · Barangay Pisaan',
        textAlign: TextAlign.center,
        style: TextStyle(color: muted, fontSize: 10),
      ),
      space(32),
      MenuCard(
        icon: Icons.assignment_outlined,
        title: 'My Reports',
        subtitle: 'Your reports and status history',
        onTap: () => open('reports'),
      ),
      MenuCard(
        icon: Icons.menu_book_outlined,
        title: 'Waste Guide',
        subtitle: 'Simple tips for everyday disposal',
        onTap: () => open('guide'),
      ),
      MenuCard(
        icon: Icons.notifications_none,
        title: 'Notifications',
        subtitle: 'Community reminders and recent activity',
        onTap: () => open('notifications'),
      ),
      MenuCard(
        icon: Icons.info_outline,
        title: 'About Limpyo Pisaan',
        subtitle: 'Our purpose and our community',
        onTap: () => open('about'),
      ),
      MenuCard(
        icon: Icons.logout,
        title: 'Log Out',
        subtitle: 'Return to the login screen',
        onTap: () => logout(context),
        danger: true,
      ),
      space(18),
      const Text(
        'Limpyo Pisaan · Community waste information\nVersion 1.3 · Barangay Pisaan',
        textAlign: TextAlign.center,
        style: TextStyle(color: muted, fontSize: 10, height: 1.8),
      ),
    ],
  );
}

class GuidePage extends StatelessWidget {
  final VoidCallback back;
  const GuidePage({super.key, required this.back});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      PageHeading(
        'Waste Guide',
        subtitle: 'Small habits. A cleaner community.',
        back: back,
      ),
      const Notice(
        'Sort waste at home and use the disposal options provided in your community.',
        icon: Icons.menu_book_outlined,
      ),
      for (final item in [
        (
          Icons.layers_outlined,
          'Segregate at the source',
          'Keep separate containers for food scraps, recyclables, and residual waste.',
          'START AT HOME',
        ),
        (
          Icons.grass_outlined,
          'Biodegradable',
          'Fruit peels, vegetable scraps, and leaves. Compost where safe and suitable.',
          'FOOD SCRAPS · LEAVES',
        ),
        (
          Icons.recycling_outlined,
          'Recyclable',
          'Clean, dry paper, bottles, and cans. Keep them free from food and liquids.',
          'PAPER · BOTTLES · CANS',
        ),
        (
          Icons.delete_outline,
          'Residual',
          'Used wrappers and soiled packaging. Contain securely; do not mix with recyclables.',
          'WRAPPERS · SOILED PACKAGING',
        ),
        (
          Icons.volunteer_activism_outlined,
          'Dispose with care',
          'Never burn or dump waste. Keep sharps separate and ask about safe handling.',
          'KEEP PATHWAYS AND DRAINS CLEAR',
        ),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Surface(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconTile(item.$1),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      space(10),
                      Text(
                        item.$3,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 12,
                          height: 1.8,
                        ),
                      ),
                      space(16),
                      const Divider(),
                      space(9),
                      Text(
                        item.$4,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 8,
                          letterSpacing: .4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      const SectionTitle('Everyday care, close to home'),
      PhotoCard(communityPhotos[7]),
      space(12),
      const Notice(
        'Keep reusable bottles together and separate from residual waste.',
        icon: Icons.recycling_outlined,
      ),
      space(22),
      PhotoCard(communityPhotos[6]),
      space(12),
      const Notice('Keep wrappers and household waste out of drains.'),
      space(22),
      PhotoCard(communityPhotos[4]),
      space(12),
      const Notice(
        'Never burn household waste. Separate and contain waste for proper disposal.',
      ),
    ],
  );
}

class NotificationsPage extends StatelessWidget {
  final AppState state;
  final OpenPage open;
  final VoidCallback back;
  const NotificationsPage({
    super.key,
    required this.state,
    required this.open,
    required this.back,
  });
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      PageHeading(
        'Notifications',
        subtitle: 'Reminders worth keeping close.',
        back: back,
      ),
      SectionTitle(
        'Recent activity',
        action: TextButton(
          onPressed: state.notificationsRead
              ? null
              : () async {
                  try {
                    await state.markRead();
                  } catch (_) {
                    if (context.mounted) {
                      showMessage(context, 'Read status could not be saved.');
                    }
                  }
                },
          child: Text(
            state.notificationsRead ? 'All caught up' : 'Mark all read',
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ),
      if (state.reports.any((report) => !report.sample))
        MenuCard(
          icon: Icons.assignment_turned_in_outlined,
          title: 'Your report is saved',
          subtitle:
              '${state.reports.first.id} is saved in My Reports.${state.notificationsRead ? '' : '\nUnread'}',
          onTap: () => open('details:${state.reports.first.id}'),
        ),
      MenuCard(
        icon: Icons.feed_outlined,
        title: 'A community reminder is available',
        subtitle:
            'Keep waste secured before collection. Read the community update.\n23 Oct 2026${state.notificationsRead ? '' : ' · Unread'}',
        onTap: () => open('post:0'),
      ),
      MenuCard(
        icon: Icons.local_shipping_outlined,
        title: 'Prepare your waste for collection',
        subtitle:
            'Separate your waste, secure your bags, and keep pathways clear.',
        onTap: () => open('collection'),
      ),
    ],
  );
}

class AboutPage extends StatelessWidget {
  final VoidCallback back;
  const AboutPage({super.key, required this.back});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      PageHeading('About Limpyo Pisaan', back: back),
      Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset('assets/logo.png', width: 76, height: 76),
            ),
            space(18),
            Center(
              child: Text(
                'Limpyo Pisaan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            space(9),
            const Center(
              child: Text(
                'A cleaner community starts with us.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ),
            space(25),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset('assets/community.png'),
            ),
            space(27),
            Text(
              'Designed for our community.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            space(14),
            const Text(
              'A community waste information and reporting app for residents of Purok 3, Barangay Pisaan. It brings together community updates, collection information, and private waste-related concerns in one calm, accessible place.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.8),
            ),
            space(18),
            const Text(
              'For neighbors without a smartphone, shared household devices, barangay bulletin notices, and word of mouth remain important ways to stay informed.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.8),
            ),
            space(25),
            const Notice(
              'A little care goes a long way. Keep up with community updates, learn better disposal habits, and keep track of waste concerns in your neighborhood.',
            ),
          ],
        ),
      ),
    ],
  );
}
