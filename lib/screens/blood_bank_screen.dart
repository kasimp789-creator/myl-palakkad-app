import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/palakkad_data.dart';
import '../models/member_model.dart';
import '../services/app_state_service.dart';

class BloodBankScreen extends StatefulWidget {
  const BloodBankScreen({super.key});

  @override
  State<BloodBankScreen> createState() => _BloodBankScreenState();
}

class _BloodBankScreenState extends State<BloodBankScreen> {
  String selectedBloodFilter = 'All';
  String selectedMandalamFilter = 'All';
  bool onlyWhiteGuard = false;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber, String bloodGroup) async {
    final message = Uri.encodeComponent(
      'അസ്സലാമു അലൈക്കും, പാലക്കാട് ജില്ലാ യൂത്ത് ലീഗ് ആപ്പിൽ നിന്നാണ്. അടിയന്തരമായി $bloodGroup രക്തം ആവശ്യമുണ്ട്.',
    );
    final Uri whatsappUri = Uri.parse('https://wa.me/91$phoneNumber?text=$message');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAddDonorModal() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final shakhaCtrl = TextEditingController();
    String mandalam = 'മണ്ണാർക്കാട്';
    String panchayat = 'കാരാകുറുശ്ശി';
    String bloodGroup = 'O+';
    bool isWG = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final panchayats = palakkadMandalams[mandalam] ?? [];
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'പുതിയ രക്തദാതാവിനെ / വൈറ്റ് ഗാർഡിനെ ചേർക്കുക',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'പേര്', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(labelText: 'ഫോൺ നമ്പർ', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: bloodGroup,
                            decoration: const InputDecoration(labelText: 'Blood', border: OutlineInputBorder()),
                            items: bloodGroupsList.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                            onChanged: (val) => setModalState(() => bloodGroup = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: mandalam,
                      decoration: const InputDecoration(labelText: 'മണ്ഡലം', border: OutlineInputBorder()),
                      items: palakkadMandalams.keys.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          mandalam = val!;
                          panchayat = palakkadMandalams[val]!.first;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: panchayat,
                      decoration: const InputDecoration(labelText: 'പഞ്ചായത്ത് / മുനിസിപ്പാലിറ്റി', border: OutlineInputBorder()),
                      items: panchayats.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (val) => setModalState(() => panchayat = val!),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: shakhaCtrl,
                      decoration: const InputDecoration(labelText: 'ശാഖ', border: OutlineInputBorder()),
                    ),
                    SwitchListTile(
                      title: const Text('വൈറ്റ് ഗാർഡ് വളണ്ടിയർ ആണോ?'),
                      value: isWG,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (val) => setModalState(() => isWG = val),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emergencyRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;
                          AppStateService.instance.addBloodDonor(
                            MemberModel(
                              memberId: 'MYL-WG-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
                              name: nameCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              bloodGroup: bloodGroup,
                              mandalam: mandalam,
                              panchayat: panchayat,
                              shakha: shakhaCtrl.text.trim().isEmpty ? 'ടൗൺ ശാഖ' : shakhaCtrl.text.trim(),
                              designation: isWG ? 'വൈറ്റ് ഗാർഡ് വളണ്ടിയർ' : 'മെമ്പർ',
                              isWhiteGuard: isWG,
                            ),
                          );
                          Navigator.pop(ctx);
                          setState(() {});
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('ഡയറക്ടറിയിലേക്ക് ചേർക്കുക'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allDonors = AppStateService.instance.bloodDonors;
    final filteredDonors = allDonors.where((d) {
      final matchBlood = selectedBloodFilter == 'All' || d.bloodGroup == selectedBloodFilter;
      final matchMandalam = selectedMandalamFilter == 'All' || d.mandalam == selectedMandalamFilter;
      final matchWG = !onlyWhiteGuard || d.isWhiteGuard;
      return matchBlood && matchMandalam && matchWG;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('വൈറ്റ് ഗാർഡ് & രക്തദാന സേവനം'),
        backgroundColor: AppColors.emergencyRed,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.emergencyRed,
        foregroundColor: Colors.white,
        onPressed: _showAddDonorModal,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('രജിസ്റ്റർ ചെയ്യുക'),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', ...bloodGroupsList].map((bg) {
                      final isSelected = selectedBloodFilter == bg;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(bg == 'All' ? 'എല്ലാ ഗ്രൂപ്പും' : bg),
                          selected: isSelected,
                          selectedColor: AppColors.emergencyRed,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => setState(() => selectedBloodFilter = bg),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedMandalamFilter,
                        decoration: const InputDecoration(
                          labelText: 'മണ്ഡലം ഫിൽട്ടർ',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: ['All', ...palakkadMandalams.keys]
                            .map((m) => DropdownMenuItem(value: m, child: Text(m == 'All' ? 'എല്ലാ മണ്ഡലങ്ങളും' : m)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedMandalamFilter = val!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('White Guard'),
                      selected: onlyWhiteGuard,
                      selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                      onSelected: (val) => setState(() => onlyWhiteGuard = val),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Donor List
          Expanded(
            child: filteredDonors.isEmpty
                ? const Center(child: Text('തിരഞ്ഞെടുത്ത ഫിൽട്ടറിൽ രക്തദാതാക്കൾ ലഭ്യമല്ല.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredDonors.length,
                    itemBuilder: (context, index) {
                      final donor = filteredDonors[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.emergencyRed,
                            child: Text(
                              donor.bloodGroup,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(donor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              if (donor.isWhiteGuard)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'WHITE GUARD',
                                    style: TextStyle(fontSize: 9, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('${donor.mandalam} • ${donor.panchayat} (${donor.shakha})
ഫോൺ: ${donor.phone}'),
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.call, color: AppColors.primaryGreen),
                                tooltip: 'നേരിട്ട് വിളിക്കുക',
                                onPressed: () => _makePhoneCall(donor.phone),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                                tooltip: 'WhatsApp സന്ദേശം',
                                onPressed: () => _openWhatsApp(donor.phone, donor.bloodGroup),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
