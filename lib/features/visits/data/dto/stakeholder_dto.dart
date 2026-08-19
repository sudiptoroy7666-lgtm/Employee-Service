class StakeholderDto {
  StakeholderDto.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        name = j['name']?.toString() ?? j['companyName']?.toString() ?? 'Unknown',
        type = j['stakeholderType']?['name']?.toString() ?? 'dealer',
        contact = j['contact']?.toString() ?? '';

  final String id;
  final String name;
  final String type;
  final String contact;
}
