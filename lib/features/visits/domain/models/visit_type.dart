enum VisitType {
  newLead,
  followUp,
  promotion,
  collection;

  String get label {
    switch (this) {
      case VisitType.newLead:
        return 'New Lead';
      case VisitType.followUp:
        return 'Follow Up';
      case VisitType.promotion:
        return 'Promotion';
      case VisitType.collection:
        return 'Collection';
    }
  }
}
