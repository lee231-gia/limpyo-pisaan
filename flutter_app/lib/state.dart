import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStage { welcome, login, app }

const issueTypes = [
  'Uncollected trash',
  'Illegal dumping',
  'Overflowing trash bin',
  'Other waste-related concern',
];

class ShowcaseEntry {
  final String id, title, body, author, date;
  final String? photo;
  const ShowcaseEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    required this.date,
    this.photo,
  });
  factory ShowcaseEntry.fromJson(Map<String, dynamic> json) => ShowcaseEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    author: json['author'] as String,
    date: json['date'] as String,
    photo: json['photo'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'author': author,
    'date': date,
    'photo': photo,
  };
}

class ReportDraft {
  String type, location, description;
  String? photo;
  ReportDraft({
    this.type = '',
    this.location = '',
    this.description = '',
    this.photo,
  });
  Map<String, String> validate() => {
    if (type.trim().isEmpty) 'type': 'Choose an issue type.',
    if (location.trim().isEmpty)
      'location': 'Enter a location or nearby landmark.',
    if (description.trim().isEmpty)
      'description': 'Describe the waste-related concern.',
  };
}

class WasteReport {
  final String id, type, location, description, status, date;
  final String? photo;
  final bool sample;
  const WasteReport({
    required this.id,
    required this.type,
    required this.location,
    required this.description,
    required this.status,
    required this.date,
    this.photo,
    this.sample = false,
  });
  factory WasteReport.fromJson(Map<String, dynamic> json) => WasteReport(
    id: (json['id'] as String).replaceFirst(RegExp(r'^DEMO-LP-'), 'LP-'),
    type: json['type'] as String,
    location: json['location'] as String,
    description: json['description'] as String,
    status: json['status'] as String,
    date: json['date'] as String,
    photo: json['photo'] as String?,
    sample: json['sample'] == true,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'location': location,
    'description': description,
    'status': status,
    'date': date,
    'photo': photo,
    'sample': sample,
  };
}

String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class AppState extends ChangeNotifier {
  final SharedPreferences prefs;
  late AuthStage stage;
  late String name, email;
  late List<WasteReport> reports;
  List<ShowcaseEntry> showcases = [];
  late bool notificationsRead;
  AppState(this.prefs) {
    stage = prefs.getBool('signedIn') == true
        ? AuthStage.app
        : prefs.getBool('welcomed') == true
        ? AuthStage.login
        : AuthStage.welcome;
    name = prefs.getString('name') ?? 'Resident';
    if (['Demo Resident', 'Facebook Demo Resident'].contains(name)) {
      name = 'Resident';
    }
    email = prefs.getString('email') ?? '';
    if (email == 'resident@example.com') email = '';
    notificationsRead = prefs.getBool('notificationsRead') ?? false;
    try {
      showcases = (jsonDecode(prefs.getString('showcases') ?? '[]') as List)
          .map(
            (item) =>
                ShowcaseEntry.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      showcases = [];
    }
    try {
      final data = prefs.getString('reports');
      reports = data == null
          ? <WasteReport>[]
          : (jsonDecode(data) as List)
                .map(
                  (item) => WasteReport.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .where((report) => !report.sample)
                .toList();
    } catch (_) {
      reports = <WasteReport>[];
    }
  }
  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
  Future<void> welcomeDone() async {
    await prefs.setBool('welcomed', true);
    stage = AuthStage.login;
    notifyListeners();
  }

  Future<void> login(String fullName, String address) async {
    await prefs.setString('name', fullName.trim());
    await prefs.setString('email', address.trim());
    await prefs.setBool('welcomed', true);
    await prefs.setBool('signedIn', true);
    name = fullName.trim();
    email = address.trim();
    stage = AuthStage.app;
    notifyListeners();
  }

  Future<void> logout() async {
    await prefs.setBool('signedIn', false);
    stage = AuthStage.login;
    notifyListeners();
  }

  Future<WasteReport> submitReport(ReportDraft draft) async {
    if (draft.validate().isNotEmpty) {
      throw ArgumentError('Complete the required report fields.');
    }
    final maxId = reports.fold<int>(0, (value, report) {
      final id = int.tryParse(report.id.split('-').last) ?? 0;
      return id > value ? id : value;
    });
    final report = WasteReport(
      id: 'LP-${(maxId + 1).toString().padLeft(3, '0')}',
      type: draft.type.trim(),
      location: draft.location.trim(),
      description: draft.description.trim(),
      status: 'Pending',
      date: formatDate(DateTime.now()),
      photo: draft.photo,
    );
    final next = [report, ...reports];
    if (!await prefs.setString(
      'reports',
      jsonEncode(next.map((item) => item.toJson()).toList()),
    )) {
      throw StateError('Could not save the report on this device.');
    }
    reports = next;
    notificationsRead = false;
    await prefs.setBool('notificationsRead', false);
    notifyListeners();
    return report;
  }

  Future<void> addShowcase(String title, String body, String? photo) async {
    if (title.trim().isEmpty || body.trim().isEmpty) {
      throw ArgumentError('Add a title and story.');
    }
    final entry = ShowcaseEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      body: body.trim(),
      author: name,
      date: formatDate(DateTime.now()),
      photo: photo,
    );
    final next = [entry, ...showcases];
    if (!await prefs.setString(
      'showcases',
      jsonEncode(next.map((item) => item.toJson()).toList()),
    )) {
      throw StateError('Could not save showcase.');
    }
    showcases = next;
    notifyListeners();
  }

  Future<void> markRead() async {
    await prefs.setBool('notificationsRead', true);
    notificationsRead = true;
    notifyListeners();
  }
}
