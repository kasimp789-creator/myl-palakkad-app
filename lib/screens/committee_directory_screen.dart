import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/palakkad_data.dart';

class CommitteeDirectoryScreen extends StatefulWidget {
  const CommitteeDirectoryScreen({super.key});

  @override
  State<CommitteeDirectoryScreen> createState() => _CommitteeDirectoryScreenState();
}

class _CommitteeDirectoryScreenState extends State<CommitteeDirectoryScreen> {
  String selectedMandalam = 'മണ്ണാർക്കാട്';

  final List<Map<String, String>> districtOfficeBearers = const [
    {'name': 'ജില്ലാ പ്രസിഡന്റ്', 'role': 'President - MYL Palakkad', 'phone': '9847000001'},
    {'name': 'ജില്ലാ ജനറൽ സെക്രട്ടറി', 'role': 'General Secretary - MYL Palakkad', 'phone': '9847000002'},
    {'name': 'ജില്ലാ ട്രഷറർ', 'role': 'Treasurer - MYL Palakkad', 'phone': '9847000003'},
    {'name': 'വൈറ്റ് ഗാർഡ് ജില്ലാ ക്യാപ്റ്റൻ', 'role': 'District Captain - White Guard', 'phone': '9847000004'},
  ];

  Future<void> _callNumber(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final panchayats = palakkadMandalams[selectedMandalam] ?? [];

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('സംഘടനാ ഘടന & ഡയറക്ടറി'),
        backgroundColor: AppColors.darkSlate,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'പാലക്കാട് ജില്ലാ കമ്മിറ്റി ഭാരവാഹികൾ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...districtOfficeBearers.map((ob) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.person),
                  ),
                  title: Text(ob['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(ob['role']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.phone_in_talk, color: AppColors.primaryGreen),
                    onPressed: () => _callNumber(ob['phone']!),
                  ),
                ),
              )),
          const Divider(height: 32),
          const Text(
            'മണ്ഡലം & പഞ്ചായത്ത്/മുനിസിപ്പൽ കമ്മിറ്റികൾ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedMandalam,
            decoration: const InputDecoration(
              labelText: 'നിയോജക മണ്ഡലം തിരഞ്ഞെടുക്കുക',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: palakkadMandalams.keys.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) => setState(() => selectedMandalam = val!),
          ),
          const SizedBox(height: 12),
          ...panchayats.map((p) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  leading: const Icon(Icons.location_city, color: AppColors.primaryGreen),
                  title: Text(p, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$selectedMandalam മണ്ഡലം'),
                  children: [
                    ListTile(
                      dense: true,
                      title: const Text('പഞ്ചായത്ത്/മുനിസിപ്പൽ പ്രസിഡന്റ്'),
                      trailing: IconButton(
                        icon: const Icon(Icons.call, size: 20, color: AppColors.primaryGreen),
                        onPressed: () => _callNumber('9847000000'),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      title: const Text('പഞ്ചായത്ത്/മുനിസിപ്പൽ ജനറൽ സെക്രട്ടറി'),
                      trailing: IconButton(
                        icon: const Icon(Icons.call, size: 20, color: AppColors.primaryGreen),
                        onPressed: () => _callNumber('9847000000'),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
