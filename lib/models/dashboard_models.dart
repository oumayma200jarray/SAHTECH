// lib/models/admin_stats_model.dart
class AdminStats {
  final String totalPatients;
  final String totalSpecialists;
  final String pendingValidations;
  final String flaggedContent;

  AdminStats({
    required this.totalPatients,
    required this.totalSpecialists,
    required this.pendingValidations,
    required this.flaggedContent,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalPatients: json['totalPatients'] ?? '0',
      totalSpecialists: json['totalSpecialists'] ?? '0',
      pendingValidations: json['pendingValidations'] ?? '0',
      flaggedContent: json['flaggedContent'] ?? '0',
    );
  }
}

class SpecialistValidation {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final String imageUrl;

  SpecialistValidation({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.imageUrl,
  });

  factory SpecialistValidation.fromJson(Map<String, dynamic> json) {
    return SpecialistValidation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

// lib/models/chat_model.dart
enum MessageType { text, image, pdf }

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final MessageType type;
  final String? attachmentUrl;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.type = MessageType.text,
    this.attachmentUrl,
    required this.timestamp,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    MessageType mType = MessageType.text;
    if (json['type'] == 'image') mType = MessageType.image;
    if (json['type'] == 'pdf') mType = MessageType.pdf;

    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',
      type: mType,
      attachmentUrl: json['attachmentUrl'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isMe: json['isMe'] ?? false,
    );
  }
}

class ChatConversation {
  final String doctorName;
  final String specialty;
  final String doctorImageUrl;
  final List<ChatMessage> messages;

  ChatConversation({
    required this.doctorName,
    required this.specialty,
    required this.doctorImageUrl,
    required this.messages,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    var list = json['messages'] as List? ?? [];
    List<ChatMessage> msgs = list.map((i) => ChatMessage.fromJson(i)).toList();

    return ChatConversation(
      doctorName: json['doctorName'] ?? 'Médecin',
      specialty: json['specialty'] ?? 'Spécialiste',
      doctorImageUrl:
          json['doctorImageUrl'] ?? 'https://i.pravatar.cc/150?u=doc',
      messages: msgs,
    );
  }

  factory ChatConversation.empty() {
    return ChatConversation(
      doctorName: 'Chargement...',
      specialty: '',
      doctorImageUrl: 'https://i.pravatar.cc/150?u=doc',
      messages: [],
    );
  }

  factory ChatConversation.placeholder(String name) {
    return ChatConversation(
      doctorName: name,
      specialty: 'Spécialiste',
      doctorImageUrl: 'https://i.pravatar.cc/150?u=doc',
      messages: [],
    );
  }
}

// lib/models/specialist_dashboard_model.dart
class SpecialistStats {
  final int totalPatients;
  final double patientGrowthPercent;
  final int adherencePercent;
  final double adherenceGrowthPercent;
  final int activeAlerts;
  final double alertsGrowthPercent;
  final String doctorName;

  SpecialistStats({
    required this.totalPatients,
    required this.patientGrowthPercent,
    required this.adherencePercent,
    required this.adherenceGrowthPercent,
    required this.activeAlerts,
    required this.alertsGrowthPercent,
    required this.doctorName,
  });

  factory SpecialistStats.fromJson(Map<String, dynamic> json) {
    return SpecialistStats(
      totalPatients: json['totalPatients'] ?? 0,
      patientGrowthPercent: (json['patientGrowthPercent'] ?? 0).toDouble(),
      adherencePercent: json['adherencePercent'] ?? 0,
      adherenceGrowthPercent: (json['adherenceGrowthPercent'] ?? 0).toDouble(),
      activeAlerts: json['activeAlerts'] ?? 0,
      alertsGrowthPercent: (json['alertsGrowthPercent'] ?? 0).toDouble(),
      doctorName: json['doctorName'] ?? 'Spécialiste',
    );
  }

  factory SpecialistStats.zero() {
    return SpecialistStats(
      totalPatients: 0,
      patientGrowthPercent: 0.0,
      adherencePercent: 0,
      adherenceGrowthPercent: 0.0,
      activeAlerts: 0,
      alertsGrowthPercent: 0.0,
      doctorName: 'Chargement...',
    );
  }
}

class SpecialistAppointment {
  final String id;
  final String time;
  final String patientName;
  final String reason;
  final String score;
  final String imc;

  SpecialistAppointment({
    required this.id,
    required this.time,
    required this.patientName,
    required this.reason,
    required this.score,
    required this.imc,
  });

  factory SpecialistAppointment.fromJson(Map<String, dynamic> json) {
    return SpecialistAppointment(
      id: json['id'] ?? '',
      time: json['time'] ?? '',
      patientName: json['patientName'] ?? '',
      reason: json['reason'] ?? '',
      score: json['score'] ?? '',
      imc: json['imc'] ?? '',
    );
  }
}

class PatientFollowUp {
  final String name;
  final String zone;
  final int romProgress;
  final double growth;
  final String imageUrl;

  PatientFollowUp({
    required this.name,
    required this.zone,
    required this.romProgress,
    required this.growth,
    required this.imageUrl,
  });

  factory PatientFollowUp.fromJson(Map<String, dynamic> json) {
    return PatientFollowUp(
      name: json['name'] ?? '',
      zone: json['zone'] ?? '',
      romProgress: json['romProgress'] ?? 0,
      growth: (json['growth'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
