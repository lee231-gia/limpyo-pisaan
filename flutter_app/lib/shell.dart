import 'package:flutter/material.dart';
import 'state.dart';
import 'ui.dart';
import 'community.dart';
import 'reports.dart';
import 'profile.dart';
import 'showcase_authoring.dart';

class AppShell extends StatefulWidget {
  final AppState state;
  const AppShell({super.key, required this.state});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final history = <String>['home'];
  ReportDraft draft = ReportDraft();
  WasteReport? latest;
  bool reportSaving = false;
  String get page => history.last;
  void open(String route) {
    if (reportSaving || route == page) return;
    setState(() => history.add(route));
  }

  void tab(String route) {
    if (reportSaving) return;
    setState(() {
      history.clear();
      history.add(route);
    });
  }

  void back() {
    if (reportSaving) return;
    setState(() {
      if (history.length > 1) {
        history.removeLast();
      } else {
        history[0] = 'home';
      }
    });
  }

  int get selected {
    if (page.startsWith('post:') ||
        page.startsWith('show:') ||
        page == 'updates' ||
        page.startsWith('resident:')) {
      return 1;
    }
    if (page == 'collection' || page == 'dropoff') return 2;
    if (['report', 'review', 'success'].contains(page)) return 3;
    if ([
          'profile',
          'reports',
          'guide',
          'notifications',
          'about',
        ].contains(page) ||
        page.startsWith('details:')) {
      return 4;
    }
    return 0;
  }

  Widget content() {
    switch (page) {
      case 'home':
        return HomePage(state: widget.state, open: open);
      case 'updates':
        return UpdatesPage(open: open, state: widget.state);
      case 'collection':
        return CollectionPage(open: open);
      case 'dropoff':
        return DropoffPage(back: back);
      case 'report':
        return ReportFormPage(draft: draft, review: () => open('review'));
      case 'review':
        return ReviewPage(
          state: widget.state,
          draft: draft,
          back: back,
          onSaving: (value) {
            if (mounted) setState(() => reportSaving = value);
          },
          onSubmitted: (report) {
            setState(() {
              reportSaving = false;
              latest = report;
              draft = ReportDraft();
              history.removeWhere(
                (route) => route == 'review' || route == 'report',
              );
              history.add('success');
            });
          },
        );
      case 'success':
        return ReportSuccessPage(
          report: latest,
          open: (route) {
            tab(route);
          },
        );
      case 'profile':
        return ProfilePage(state: widget.state, open: open);
      case 'reports':
        return ReportsPage(state: widget.state, open: open, back: back);
      case 'guide':
        return GuidePage(back: back);
      case 'notifications':
        return NotificationsPage(state: widget.state, open: open, back: back);
      case 'about':
        return AboutPage(back: back);
    }
    if (page.startsWith('post:')) {
      return PostPage(
        index: int.tryParse(page.split(':').last) ?? 0,
        back: back,
      );
    }
    if (page.startsWith('show:')) {
      return PostPage(
        index: page.split(':').last == 'lane' ? 0 : 1,
        back: back,
      );
    }
    if (page.startsWith('resident:')) {
      final entries = widget.state.showcases.where(
        (entry) => entry.id == page.substring(9),
      );
      if (entries.isNotEmpty) {
        return ResidentShowcasePage(entry: entries.first, back: back);
      }
    }
    if (page.startsWith('details:')) {
      final id = page.substring(8);
      final matches = widget.state.reports.where((report) => report.id == id);
      if (matches.isNotEmpty) {
        return ReportDetailsPage(report: matches.first, back: back);
      }
    }
    return PageBody(children: [PageHeading('Page unavailable', back: back)]);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !reportSaving && history.length == 1 && page == 'home',
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && !reportSaving) back();
    },
    child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Brand(),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: reportSaving ? null : () => open('notifications'),
            icon: Badge(
              isLabelVisible: !widget.state.notificationsRead,
              smallSize: 5,
              backgroundColor: const Color(0xFF8FA779),
              child: const Icon(Icons.notifications_none, size: 22),
            ),
          ),
          const SizedBox(width: 10),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: KeyedSubtree(key: ValueKey(page), child: content()),
          ),
        ),
      ),
      bottomNavigationBar: page == 'success'
          ? null
          : NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: reportSaving
                  ? null
                  : (index) => tab(
                      [
                        'home',
                        'updates',
                        'collection',
                        'report',
                        'profile',
                      ][index],
                    ),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.feed_outlined),
                  selectedIcon: Icon(Icons.feed),
                  label: 'Updates',
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_shipping_outlined),
                  selectedIcon: Icon(Icons.local_shipping),
                  label: 'Collection',
                ),
                NavigationDestination(
                  icon: Icon(Icons.edit_note_outlined),
                  selectedIcon: Icon(Icons.edit_note),
                  label: 'Report',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
    ),
  );
}
