class InventoryItemDto {
  InventoryItemDto.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        name = j['seedType']?['name']?.toString() ?? j['name']?.toString() ?? 'Unknown Product',
        price = double.tryParse(j['unitPrice']?.toString() ?? '0') ?? 0.0,
        unit = j['packetSize']?['name']?.toString() ?? 'kg',
        category = j['seedType']?['category']?.toString() ?? 'General';

  final String id;
  final String name;
  final double price;
  final String unit;
  final String category;
}
