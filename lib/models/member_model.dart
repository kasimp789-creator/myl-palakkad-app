class MemberModel {
  final String memberId;
  final String name;
  final String phone;
  final String bloodGroup;
  final String mandalam;
  final String panchayat;
  final String shakha;
  final String designation;
  final bool isWhiteGuard;

  MemberModel({
    required this.memberId,
    required this.name,
    required this.phone,
    required this.bloodGroup,
    required this.mandalam,
    required this.panchayat,
    required this.shakha,
    required this.designation,
    this.isWhiteGuard = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'name': name,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'mandalam': mandalam,
      'panchayat': panchayat,
      'shakha': shakha,
      'designation': designation,
      'isWhiteGuard': isWhiteGuard,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
