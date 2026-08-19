enum FollowUpOutcome { interested, notInterested, followUpAgain, converted }

extension FollowUpOutcomeLabel on FollowUpOutcome {
  String get label {
    switch (this) {
      case FollowUpOutcome.interested: return 'Interested';
      case FollowUpOutcome.notInterested: return 'Not Interested';
      case FollowUpOutcome.followUpAgain: return 'Follow Up Again';
      case FollowUpOutcome.converted: return 'Converted to Order';
    }
  }
}

enum FollowUpSyncStatus { synced, pending, failed }

class FollowUp {
  final String id;
  final String leadId;
  final String? leadName;
  final DateTime followUpDate;
  final String? notes;
  final FollowUpOutcome? outcome;
  final DateTime createdAt;
  final bool isLocalOnly;
  final FollowUpSyncStatus syncStatus;

  const FollowUp({
    required this.id,
    required this.leadId,
    this.leadName,
    required this.followUpDate,
    this.notes,
    this.outcome,
    DateTime? createdAt,
    this.isLocalOnly = false,
    this.syncStatus = FollowUpSyncStatus.synced,
  }) : createdAt = createdAt ?? const _DefaultDateTime();

  FollowUp copyWith({
    String? id,
    String? leadId,
    String? leadName,
    DateTime? followUpDate,
    String? notes,
    FollowUpOutcome? outcome,
    DateTime? createdAt,
    bool? isLocalOnly,
    FollowUpSyncStatus? syncStatus,
  }) {
    return FollowUp(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      leadName: leadName ?? this.leadName,
      followUpDate: followUpDate ?? this.followUpDate,
      notes: notes ?? this.notes,
      outcome: outcome ?? this.outcome,
      createdAt: createdAt ?? this.createdAt,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();
  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}
