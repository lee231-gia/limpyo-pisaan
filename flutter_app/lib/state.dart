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

class AnnouncementEntry {
  final String id, title, body, date;
  final String category;
  const AnnouncementEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.category,
  });
  factory AnnouncementEntry.fromJson(Map<String, dynamic> json) =>
      AnnouncementEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        date: json['date'] as String,
        category: json['category'] as String,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'date': date,
    'category': category,
  };
}

class GuideEntry {
  final String id, title, body, date;
  const GuideEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });
  factory GuideEntry.fromJson(Map<String, dynamic> json) => GuideEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    date: json['date'] as String,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'date': date,
  };
}

class ServiceSettings {
  final String collectionDay, collectionTime, serviceArea, updateWindow;
  final String dropoffName, dropoffLandmark, acceptedWaste, operatingHours;
  final double dropoffPinX, dropoffPinY;
  const ServiceSettings({
    this.collectionDay = 'Monday',
    this.collectionTime = '8:00 AM',
    this.serviceArea = 'Upper Pisaan',
    this.updateWindow = '11:00 AM',
    this.dropoffName = 'Community drop-off point',
    this.dropoffLandmark = 'Purok 3 · Lower Pisaan',
    this.acceptedWaste = 'Plastic bottles · clean and dry',
    this.operatingHours = '8:00 AM – 11:00 AM',
    this.dropoffPinX = .28,
    this.dropoffPinY = .43,
  });
  factory ServiceSettings.fromJson(
    Map<String, dynamic> json,
  ) => ServiceSettings(
    collectionDay: json['collectionDay'] as String? ?? 'Monday',
    collectionTime: json['collectionTime'] as String? ?? '8:00 AM',
    serviceArea: json['serviceArea'] as String? ?? 'Upper Pisaan',
    updateWindow: json['updateWindow'] as String? ?? '11:00 AM',
    dropoffName: json['dropoffName'] as String? ?? 'Community drop-off point',
    dropoffLandmark:
        json['dropoffLandmark'] as String? ?? 'Purok 3 · Lower Pisaan',
    acceptedWaste:
        json['acceptedWaste'] as String? ?? 'Plastic bottles · clean and dry',
    operatingHours: json['operatingHours'] as String? ?? '8:00 AM – 11:00 AM',
    dropoffPinX: (json['dropoffPinX'] as num?)?.toDouble() ?? .28,
    dropoffPinY: (json['dropoffPinY'] as num?)?.toDouble() ?? .43,
  );
  Map<String, dynamic> toJson() => {
    'collectionDay': collectionDay,
    'collectionTime': collectionTime,
    'serviceArea': serviceArea,
    'updateWindow': updateWindow,
    'dropoffName': dropoffName,
    'dropoffLandmark': dropoffLandmark,
    'acceptedWaste': acceptedWaste,
    'operatingHours': operatingHours,
    'dropoffPinX': dropoffPinX,
    'dropoffPinY': dropoffPinY,
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
  final String? officialResponse;
  final bool sample;
  const WasteReport({
    required this.id,
    required this.type,
    required this.location,
    required this.description,
    required this.status,
    required this.date,
    this.photo,
    this.officialResponse,
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
    officialResponse: json['officialResponse'] as String?,
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
    'officialResponse': officialResponse,
    'sample': sample,
  };
  WasteReport copyWith({String? status, String? officialResponse}) =>
      WasteReport(
        id: id,
        type: type,
        location: location,
        description: description,
        status: status ?? this.status,
        date: date,
        photo: photo,
        officialResponse: officialResponse ?? this.officialResponse,
        sample: sample,
      );
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
  List<AnnouncementEntry> announcements = [];
  List<GuideEntry> guides = [];
  ServiceSettings services = const ServiceSettings();
  late bool isOfficial;
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
    isOfficial = prefs.getBool('isOfficial') ?? false;
    try {
      announcements =
          (jsonDecode(prefs.getString('announcements') ?? '[]') as List)
              .map(
                (item) => AnnouncementEntry.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList();
      final serviceData = prefs.getString('services');
      if (serviceData != null) {
        services = ServiceSettings.fromJson(
          Map<String, dynamic>.from(jsonDecode(serviceData) as Map),
        );
      }
      guides = (jsonDecode(prefs.getString('guides') ?? '[]') as List)
          .map(
            (item) =>
                GuideEntry.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      announcements = [];
      guides = [];
      services = const ServiceSettings();
    }
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

  /// Starts a presentation account without a password or remote service.
  /// This keeps the resident and management demos easy to show while all
  /// information remains in this device's local frontend storage.
  Future<void> enterDemo({required bool official}) async {
    final demoName = official ? 'Barangay Official' : 'Resident';
    final demoEmail = official
        ? 'official@pisaan.local'
        : 'resident@pisaan.local';
    await prefs.setString('name', demoName);
    await prefs.setString('email', demoEmail);
    await prefs.setBool('welcomed', true);
    await prefs.setBool('signedIn', true);
    await prefs.setBool('isOfficial', official);
    name = demoName;
    email = demoEmail;
    isOfficial = official;
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

  Future<void> setOfficialMode(bool value) async {
    if (!await prefs.setBool('isOfficial', value)) {
      throw StateError('Could not save the role on this device.');
    }
    isOfficial = value;
    notifyListeners();
  }

  Future<void> updateReport(
    String id, {
    required String status,
    String? response,
  }) async {
    final trimmedResponse = response?.trim();
    final next = reports.map((report) {
      if (report.id != id) return report;
      return report.copyWith(
        status: status,
        officialResponse: trimmedResponse == null || trimmedResponse.isEmpty
            ? report.officialResponse
            : trimmedResponse,
      );
    }).toList();
    if (!await prefs.setString(
      'reports',
      jsonEncode(next.map((item) => item.toJson()).toList()),
    )) {
      throw StateError('Could not update the report on this device.');
    }
    reports = next;
    notificationsRead = false;
    await prefs.setBool('notificationsRead', false);
    notifyListeners();
  }

  Future<void> addAnnouncement({
    required String title,
    required String body,
    String category = 'BARANGAY NOTICE',
  }) async {
    if (title.trim().isEmpty || body.trim().isEmpty) {
      throw ArgumentError('Add a title and message.');
    }
    final entry = AnnouncementEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      body: body.trim(),
      date: formatDate(DateTime.now()),
      category: category,
    );
    final next = [entry, ...announcements];
    if (!await prefs.setString(
      'announcements',
      jsonEncode(next.map((item) => item.toJson()).toList()),
    )) {
      throw StateError('Could not publish the announcement on this device.');
    }
    announcements = next;
    notificationsRead = false;
    await prefs.setBool('notificationsRead', false);
    notifyListeners();
  }

  Future<void> addGuide({required String title, required String body}) async {
    if (title.trim().isEmpty || body.trim().isEmpty) {
      throw ArgumentError('Add a title and guide text.');
    }
    final entry = GuideEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      body: body.trim(),
      date: formatDate(DateTime.now()),
    );
    final next = [entry, ...guides];
    if (!await prefs.setString(
      'guides',
      jsonEncode(next.map((item) => item.toJson()).toList()),
    )) {
      throw StateError('Could not publish the guide tip on this device.');
    }
    guides = next;
    notifyListeners();
  }

  Future<void> updateServices(ServiceSettings next) async {
    if (!await prefs.setString('services', jsonEncode(next.toJson()))) {
      throw StateError('Could not save service details on this device.');
    }
    services = next;
    notifyListeners();
  }

  Future<void> markRead() async {
    await prefs.setBool('notificationsRead', true);
    notificationsRead = true;
    notifyListeners();
  }
}
