enum ClientType {
  dealer,
  retailer,
  farmer;

  String get label {
    switch (this) {
      case ClientType.dealer:
        return 'Dealer';
      case ClientType.retailer:
        return 'Retailer';
      case ClientType.farmer:
        return 'Farmer';
    }
  }
}
