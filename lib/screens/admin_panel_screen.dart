import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/app_state_service.dart';
import '../services/pdf_generator_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool isAuthenticated = false;
  final _pinCtrl = TextEditingController();

  final _campaignTitleCtrl = TextEditingController(text: AppStateService.instance.activeCampaignTitle);
  final _targetAmountCtrl = TextEditingController(text: AppStateService.instance.targetAmount.toStringAsFixed(0));

  final _newsTitleCtrl = TextEditingController();
  final _newsDateCtrl = TextEditingController();
  final _newsDescCtrl = TextEditingController();

  void _verifyPin() {
    // ഡിഫോൾട്ട് അഡ്മിൻ പിൻ: 1973 അല്ലെങ്കിൽ 1234
    if (_pinCtrl.text.trim() == '1973' || _pinCtrl.text.trim() == '1234') {
      setState(() => isAuthenticated = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('തെറ്റായ അഡ്മിൻ പിൻ! (Default PIN: 1973)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService.instance;

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ജില്ലാ അഡ്മിൻ ലോഗിൻ'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 72, color: AppColors.primaryGreen),
              const SizedBox(height: 16),
              const Text(
                'ജില്ലാ കമ്മിറ്റി അഡ്മിൻ പാനൽ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('തുടരാൻ 4 അക്ക അഡ്മിൻ പിൻ നൽകുക (Default: 1973)', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              TextField(
                controller: _pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Admin PIN',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _verifyPin,
                  child: const Text('ലോഗിൻ ചെയ്യുക'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ജില്ലാ അഡ്മിൻ കൺട്രോൾ പാനൽ'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amberAccent,
            tabs: [
              Tab(icon: Icon(Icons.analytics_outlined), text: 'ഫണ്ട് ഓഡിറ്റ്'),
              Tab(icon: Icon(Icons.campaign_outlined), text: 'അറിയിപ്പുകൾ'),
              Tab(icon: Icon(Icons.settings_outlined), text: 'ക്രമീകരണം'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Financial Audit & PDF Export
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: AppColors.primaryGreen,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.activeCampaignTitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ആകെ സമാഹരിച്ചത്: ₹ ${appState.collectedAmount.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryGreen,
                          ),
                          onPressed: () {
                            MylPdfService.generateAdminFinancialReport(
                              campaignTitle: appState.activeCampaignTitle,
                              totalCollected: appState.collectedAmount,
                              donations: appState.donationsList,
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('സമ്പൂർണ്ണ ഓഡിറ്റ് റിപ്പോർട്ട് (PDF) ഡൗൺലോഡ് ചെയ്യുക'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('അവസാനം ലഭിച്ച സംഭാവനകൾ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                ...appState.donationsList.map((d) => Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.receipt),
                        ),
                        title: Text('${d.donorName} (₹ ${d.amount.toStringAsFixed(0)})',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${d.mandalam} • ${d.panchayat} | #${d.receiptNo} (${d.date})'),
                      ),
                    )),
              ],
            ),

            // Tab 2: Post Circulars / Announcements
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('പുതിയ അറിയിപ്പ് / സർക്കുലർ പ്രസിദ്ധീകരിക്കുക',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                TextField(
                  controller: _newsTitleCtrl,
                  decoration: const InputDecoration(labelText: 'അറിയിപ്പിന്റെ തലക്കെട്ട്', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newsDateCtrl,
                  decoration: const InputDecoration(labelText: 'തീയതി (ഉദാ: 2026 ഡിസംബർ 10)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newsDescCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'വിശദാംശങ്ങൾ', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (_newsTitleCtrl.text.trim().isEmpty) return;
                    appState.addAnnouncement(
                      _newsTitleCtrl.text.trim(),
                      _newsDateCtrl.text.trim().isEmpty ? 'ഇന്ന്' : _newsDateCtrl.text.trim(),
                      _newsDescCtrl.text.trim(),
                    );
                    _newsTitleCtrl.clear();
                    _newsDateCtrl.clear();
                    _newsDescCtrl.clear();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('അറിയിപ്പ് ഹോം സ്ക്രീനിൽ പ്രസിദ്ധീകരിച്ചു!')),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('പ്രസിദ്ധീകരിക്കുക'),
                ),
              ],
            ),

            // Tab 3: Campaign Settings
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('ചാരിറ്റി കാമ്പയിൻ ക്രമീകരണങ്ങൾ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                TextField(
                  controller: _campaignTitleCtrl,
                  decoration: const InputDecoration(labelText: 'കാമ്പയിൻ പേര്', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _targetAmountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ലക്ഷ്യമിടുന്ന തുക (Target ₹)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final newTarget = double.tryParse(_targetAmountCtrl.text) ?? 2500000;
                    appState.updateCampaignTarget(_campaignTitleCtrl.text.trim(), newTarget);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('കാമ്പയിൻ വിവരങ്ങൾ അപ്ഡേറ്റ് ചെയ്തു!')),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('മാറ്റങ്ങൾ സേവ് ചെയ്യുക'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
