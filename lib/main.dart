import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'constants/palakkad_data.dart';
import 'models/donation_model.dart';
import 'services/app_state_service.dart';
import 'services/pdf_generator_service.dart';
import 'screens/blood_bank_screen.dart';
import 'screens/committee_directory_screen.dart';
import 'screens/admin_panel_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MylPalakkadApp());
}

class MylPalakkadApp extends StatelessWidget {
  const MylPalakkadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MYL Palakkad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          secondary: AppColors.secondaryGreen,
        ),
        useMaterial3: true,
      ),
      home: const HomeDashboardScreen(),
    );
  }
}

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    AppStateService.instance.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    AppStateService.instance.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService.instance;
    final double progress = (appState.collectedAmount / appState.targetAmount).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('മുസ്‌ലിം യൂത്ത് ലീഗ്', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('പാലക്കാട് ജില്ലാ കമ്മിറ്റി', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: 'അഡ്മിൻ പാനൽ',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live Charity Tracker Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.green.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          appState.activeCampaignTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'സമാഹരിച്ച തുക (Target: ₹${(appState.targetAmount / 100000).toStringAsFixed(1)}L)',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          Text(
                            '₹ ${appState.collectedAmount.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryGreen,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CharityReceiptFormScreen()),
                          );
                        },
                        icon: const Icon(Icons.receipt_long, size: 18),
                        label: const Text('രസീത് എടുക്കുക'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            const Text('പ്രധാന സേവനങ്ങൾ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 2. Main 4 Modules + Admin
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                _buildMenuCard(
                  context,
                  icon: Icons.badge_outlined,
                  title: 'അംഗത്വ കാർഡ്',
                  subtitle: 'ID Card Generator',
                  color: AppColors.primaryGreen,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IdCardFormScreen())),
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.volunteer_activism_outlined,
                  title: 'ചാരിറ്റി ട്രാക്കർ',
                  subtitle: 'ഫണ്ട് & രസീതുകൾ',
                  color: const Color(0xFF0D7377),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CharityReceiptFormScreen())),
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.bloodtype_outlined,
                  title: 'വൈറ്റ് ഗാർഡ് & ബ്ലഡ്',
                  subtitle: 'രക്തദാന ഡയറക്ടറി',
                  color: AppColors.emergencyRed,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodBankScreen())),
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.account_tree_outlined,
                  title: 'സംഘടനാ ഘടന',
                  subtitle: 'മണ്ഡലം / പഞ്ചായത്ത്',
                  color: AppColors.darkSlate,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommitteeDirectoryScreen())),
                ),
              ],
            ),

            const SizedBox(height: 22),
            const Text('ജില്ലാ കമ്മിറ്റി അറിയിപ്പുകൾ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...appState.announcements.map((ann) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.campaign),
                    ),
                    title: Text(ann['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${ann['date']}
${ann['description']}'),
                    isThreeLine: true,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class IdCardFormScreen extends StatefulWidget {
  const IdCardFormScreen({super.key});

  @override
  State<IdCardFormScreen> createState() => _IdCardFormScreenState();
}

class _IdCardFormScreenState extends State<IdCardFormScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _shakhaCtrl = TextEditingController();

  String? selectedMandalam = 'മണ്ണാർക്കാട്';
  String? selectedPanchayat = 'കാരാകുറുശ്ശി';
  String selectedDesignation = 'മെമ്പർ';
  String selectedBloodGroup = 'O+';

  @override
  Widget build(BuildContext context) {
    final panchayatList = palakkadMandalams[selectedMandalam] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ഡിജിറ്റൽ അംഗത്വ കാർഡ്'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'പേര് (Name)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'ഫോൺ നമ്പർ', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedMandalam,
            decoration: const InputDecoration(labelText: 'നിയോജക മണ്ഡലം', border: OutlineInputBorder()),
            items: palakkadMandalams.keys.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) {
              setState(() {
                selectedMandalam = val;
                selectedPanchayat = palakkadMandalams[val]?.first;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedPanchayat,
            decoration: const InputDecoration(labelText: 'പഞ്ചായത്ത് / മുനിസിപ്പാലിറ്റി', border: OutlineInputBorder()),
            items: panchayatList.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (val) => setState(() => selectedPanchayat = val),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _shakhaCtrl,
            decoration: const InputDecoration(labelText: 'ശാഖ / യൂണിറ്റ് (Shakha)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: selectedDesignation,
                  decoration: const InputDecoration(labelText: 'സ്ഥാനം', border: OutlineInputBorder()),
                  items: [
                    'പ്രസിഡന്റ്',
                    'ജനറൽ സെക്രട്ടറി',
                    'ട്രഷറർ',
                    'വൈസ് പ്രസിഡന്റ്',
                    'ജോ. സെക്രട്ടറി',
                    'വൈറ്റ് ഗാർഡ്',
                    'മെമ്പർ'
                  ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) => setState(() => selectedDesignation = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedBloodGroup,
                  decoration: const InputDecoration(labelText: 'Blood', border: OutlineInputBorder()),
                  items: bloodGroupsList.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (val) => setState(() => selectedBloodGroup = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              final memberId = 'MYL-PKD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
              await MylPdfService.generateMembershipCard(
                memberId: memberId,
                name: _nameCtrl.text.isEmpty ? 'മുഹമ്മദ് റാഫി' : _nameCtrl.text,
                designation: selectedDesignation,
                mandalam: selectedMandalam ?? '',
                panchayat: selectedPanchayat ?? '',
                shakha: _shakhaCtrl.text.isEmpty ? 'ടൗൺ ശാഖ' : _shakhaCtrl.text,
                bloodGroup: selectedBloodGroup,
                phone: _phoneCtrl.text.isEmpty ? '9876543210' : _phoneCtrl.text,
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('ഐഡി കാർഡ് PDF ഡൗൺലോഡ് ചെയ്യുക', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class CharityReceiptFormScreen extends StatefulWidget {
  const CharityReceiptFormScreen({super.key});

  @override
  State<CharityReceiptFormScreen> createState() => _CharityReceiptFormScreenState();
}

class _CharityReceiptFormScreenState extends State<CharityReceiptFormScreen> {
  final _donorCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? selectedMandalam = 'മണ്ണാർക്കാട്';
  String? selectedPanchayat = 'കാരാകുറുശ്ശി';

  @override
  Widget build(BuildContext context) {
    final panchayatList = palakkadMandalams[selectedMandalam] ?? [];
    final appState = AppStateService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ചാരിറ്റി ഫണ്ട് രസീത്'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _donorCtrl,
            decoration: const InputDecoration(labelText: 'സംഭാവന നൽകുന്നയാളുടെ പേര്', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'തുക (₹)', prefixText: '₹ ', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedMandalam,
            decoration: const InputDecoration(labelText: 'മണ്ഡലം', border: OutlineInputBorder()),
            items: palakkadMandalams.keys.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) {
              setState(() {
                selectedMandalam = val;
                selectedPanchayat = palakkadMandalams[val]?.first;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedPanchayat,
            decoration: const InputDecoration(labelText: 'പഞ്ചായത്ത് / മുനിസിപ്പാലിറ്റി', border: OutlineInputBorder()),
            items: panchayatList.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (val) => setState(() => selectedPanchayat = val),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              final receiptNo = 'PKD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
              final amount = double.tryParse(_amountCtrl.text) ?? 500;
              final today = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
              final donorName = _donorCtrl.text.trim().isEmpty ? 'അബ്ദുൽ റഹ്മാൻ' : _donorCtrl.text.trim();

              appState.addDonation(
                DonationModel(
                  receiptNo: receiptNo,
                  campaignTitle: appState.activeCampaignTitle,
                  donorName: donorName,
                  amount: amount,
                  mandalam: selectedMandalam ?? '',
                  panchayat: selectedPanchayat ?? '',
                  date: today,
                ),
              );

              await MylPdfService.generateDonationReceipt(
                receiptNo: receiptNo,
                campaignTitle: appState.activeCampaignTitle,
                donorName: donorName,
                amount: amount,
                mandalam: selectedMandalam ?? '',
                panchayat: selectedPanchayat ?? '',
                date: today,
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('രസീത് ജനറേറ്റ് ചെയ്ത് ഷെയർ ചെയ്യുക', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
