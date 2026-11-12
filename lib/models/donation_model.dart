class DonationModel {
  final String receiptNo;
  final String campaignTitle;
  final String donorName;
  final double amount;
  final String mandalam;
  final String panchayat;
  final String date;

  DonationModel({
    required this.receiptNo,
    required this.campaignTitle,
    required this.donorName,
    required this.amount,
    required this.mandalam,
    required this.panchayat,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'receiptNo': receiptNo,
      'campaignTitle': campaignTitle,
      'donorName': donorName,
      'amount': amount,
      'mandalam': mandalam,
      'panchayat': panchayat,
      'date': date,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
