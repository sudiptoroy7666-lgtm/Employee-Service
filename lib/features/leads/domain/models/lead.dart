class Lead {
  final String id;
  final String name;
  final String contact;
  final String? company;
  final int? seedInterestId;
  final String? seedInterestName;
  final int? sourceId;
  final String? sourceName;
  final LeadStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isLocalOnly;
  final LeadSyncStatus syncStatus;

  const Lead({
    required this.id,
    required this.name,
    required this.contact,
    this.company,
    this.seedInterestId,
    this.seedInterestName,
    this.sourceId,
    this.sourceName,
    this.status = LeadStatus.newLead,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
    this.isLocalOnly = false,
    this.syncStatus = LeadSyncStatus.synced,
  }) : createdAt = createdAt ?? const _DefaultDateTime();

  Lead copyWith({
    String? id,
    String? name,
    String? contact,
    String? company,
    int? seedInterestId,
    String? seedInterestName,
    int? sourceId,
    String? sourceName,
    LeadStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLocalOnly,
    LeadSyncStatus? syncStatus,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      company: company ?? this.company,
      seedInterestId: seedInterestId ?? this.seedInterestId,
      seedInterestName: seedInterestName ?? this.seedInterestName,
      sourceId: sourceId ?? this.sourceId,
      sourceName: sourceName ?? this.sourceName,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

enum LeadStatus { newLead, contacted, qualified, converted, lost }

extension LeadStatusLabel on LeadStatus {
  String get label {
    switch (this) {
      case LeadStatus.newLead: return 'New';
      case LeadStatus.contacted: return 'Contacted';
      case LeadStatus.qualified: return 'Qualified';
      case LeadStatus.converted: return 'Converted';
      case LeadStatus.lost: return 'Lost';
    }
  }
}

enum LeadSyncStatus { synced, pending, failed }

class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();
  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}
