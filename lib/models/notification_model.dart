enum NotificationCategory {
  stockWarning,
  criticalAlert,
  outOfStockAlert,
  incomingRequest,
  transferUpdate,
  patientAvailability;

  static NotificationCategory fromString(String val) {
    switch (val.toUpperCase()) {
      case 'CRITICAL_ALERT':
      case 'CRITICALALERT':
        return NotificationCategory.criticalAlert;
      case 'OUT_OF_STOCK':
      case 'OUTOFSTOCK':
        return NotificationCategory.outOfStockAlert;
      case 'INCOMING_REQUEST':
      case 'INCOMINGREQUEST':
        return NotificationCategory.incomingRequest;
      case 'TRANSFER_UPDATE':
      case 'TRANSFERUPDATE':
        return NotificationCategory.transferUpdate;
      case 'PATIENT_AVAILABILITY':
      case 'PATIENTAVAILABILITY':
        return NotificationCategory.patientAvailability;
      case 'STOCK_WARNING':
      case 'STOCKWARNING':
      default:
        return NotificationCategory.stockWarning;
    }
  }

  String get label {
    switch (this) {
      case NotificationCategory.stockWarning:
        return 'Stock Warnings';
      case NotificationCategory.criticalAlert:
        return 'Critical Alerts';
      case NotificationCategory.outOfStockAlert:
        return 'Out-of-Stock Alerts';
      case NotificationCategory.incomingRequest:
        return 'Incoming Medicine Requests';
      case NotificationCategory.transferUpdate:
        return 'Transfer Updates';
      case NotificationCategory.patientAvailability:
        return 'Patient Availability Alerts';
    }
  }
}

class NotificationModel {
  final String id;
  final String? targetUserId;
  final String? targetPharmacyId;
  final String title;
  final String body;
  final NotificationCategory category;
  final Map<String, dynamic> dataPayload;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;

  NotificationModel({
    required this.id,
    this.targetUserId,
    this.targetPharmacyId,
    required this.title,
    required this.body,
    required this.category,
    this.dataPayload = const {},
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetUserId': targetUserId,
      'targetPharmacyId': targetPharmacyId,
      'title': title,
      'body': body,
      'category': category.name,
      'dataPayload': dataPayload,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'actionRoute': actionRoute,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      targetUserId: map['targetUserId'],
      targetPharmacyId: map['targetPharmacyId'],
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      category: NotificationCategory.fromString(map['category'] ?? 'STOCK_WARNING'),
      dataPayload: Map<String, dynamic>.from(map['dataPayload'] ?? {}),
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      actionRoute: map['actionRoute'],
    );
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      targetUserId: targetUserId,
      targetPharmacyId: targetPharmacyId,
      title: title,
      body: body,
      category: category,
      dataPayload: dataPayload,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute,
    );
  }
}
