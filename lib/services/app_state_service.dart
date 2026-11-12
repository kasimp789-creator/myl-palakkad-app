import 'package:flutter/foundation.dart';
import '../models/member_model.dart';
import '../models/donation_model.dart';

/// ലോക്കൽ ഡാറ്റയും ഫയർബേസ് സിങ്കിംഗും നിയന്ത്രിക്കുന്ന സർവീസ്
class AppStateService extends ChangeNotifier {
  static final AppStateService instance = AppStateService._internal();
  AppStateService._internal();

  String activeCampaignTitle = 'കാരുണ്യ സ്പർശം ചാരിറ്റി ഫണ്ട്';
  double targetAmount = 2500000;
  double collectedAmount = 1685000;

  final List<Map<String, String>> announcements = [
    {
      'title': 'ജില്ലാ യൂത്ത് ലീഗ് പ്രതിനിധി സമ്മേളനം',
      'date': '2026 നവംബർ 25',
      'description': 'പാലക്കാട് ജില്ലാ യൂത്ത് ലീഗ് പ്രതിനിധി സമ്മേളനത്തിലേക്കുള്ള മണ്ഡലം തല രജിസ്ട്രേഷൻ ആരംഭിച്ചു.'
    },
    {
      'title': 'വൈറ്റ് ഗാർഡ് ജില്ലാ ക്യാമ്പ്',
      'date': '2026 ഡിസംബർ 05',
      'description': 'പഞ്ചായത്ത് തല വൈറ്റ് ഗാർഡ് ക്യാപ്റ്റന്മാരുടെയും വളണ്ടിയർമാരുടെയും ഏകദിന പരിശീലന ക്യാമ്പ്.'
    },
  ];

  final List<MemberModel> bloodDonors = [
    MemberModel(
      memberId: 'MYL-PKD-1001',
      name: 'മുഹമ്മദ് റാഫി',
      phone: '9847012345',
      bloodGroup: 'O+',
      mandalam: 'മണ്ണാർക്കാട്',
      panchayat: 'കാരാകുറുശ്ശി',
      shakha: 'ടൗൺ ശാഖ',
      designation: 'വൈറ്റ് ഗാർഡ് ക്യാപ്റ്റൻ',
      isWhiteGuard: true,
    ),
    MemberModel(
      memberId: 'MYL-PKD-1002',
      name: 'ഷഫീഖ് കെ.പി',
      phone: '9745098765',
      bloodGroup: 'B+',
      mandalam: 'പട്ടാമ്പി',
      panchayat: 'വല്ലപ്പുഴ',
      shakha: 'സെൻട്രൽ ശാഖ',
      designation: 'സെക്രട്ടറി',
      isWhiteGuard: true,
    ),
    MemberModel(
      memberId: 'MYL-PKD-1003',
      name: 'അൻവർ സാദത്ത്',
      phone: '9946011223',
      bloodGroup: 'A+',
      mandalam: 'തരൂർ',
      panchayat: 'പുതുക്കോട്',
      shakha: 'നോർത്ത് ശാഖ',
      designation: 'പ്രസിഡന്റ്',
      isWhiteGuard: false,
    ),
    MemberModel(
      memberId: 'MYL-PKD-1004',
      name: 'റിയാസ് ബാബു',
      phone: '9633044556',
      bloodGroup: 'O-',
      mandalam: 'പാലക്കാട്',
      panchayat: 'പിരായിരി',
      shakha: 'കൊടുന്തിരപ്പുള്ളി',
      designation: 'വൈറ്റ് ഗാർഡ് വളണ്ടിയർ',
      isWhiteGuard: true,
    ),
  ];

  final List<DonationModel> donationsList = [
    DonationModel(
      receiptNo: 'PKD-8801',
      campaignTitle: 'കാരുണ്യ സ്പർശം ചാരിറ്റി ഫണ്ട്',
      donorName: 'അബ്ദുൽ റഹ്മാൻ ഹാജി',
      amount: 10000,
      mandalam: 'മണ്ണാർക്കാട്',
      panchayat: 'കാരാകുറുശ്ശി',
      date: '10/11/2026',
    ),
    DonationModel(
      receiptNo: 'PKD-8802',
      campaignTitle: 'കാരുണ്യ സ്പർശം ചാരിറ്റി ഫണ്ട്',
      donorName: 'യൂത്ത് ലീഗ് ടൗൺ ശാഖ',
      amount: 25000,
      mandalam: 'പട്ടാമ്പി',
      panchayat: 'കൊപ്പം',
      date: '11/11/2026',
    ),
  ];

  void addBloodDonor(MemberModel donor) {
    bloodDonors.insert(0, donor);
    notifyListeners();
  }

  void addDonation(DonationModel donation) {
    donationsList.insert(0, donation);
    collectedAmount += donation.amount;
    notifyListeners();
  }

  void addAnnouncement(String title, String date, String desc) {
    announcements.insert(0, {
      'title': title,
      'date': date,
      'description': desc,
    });
    notifyListeners();
  }

  void updateCampaignTarget(String title, double newTarget) {
    activeCampaignTitle = title;
    targetAmount = newTarget;
    notifyListeners();
  }
}
