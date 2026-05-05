import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color kBlue = Colors.blue;
const Color kGray = Colors.grey;
const Color kFieldBg = Color(0xFFF5F5F5);
const Color kRed = Colors.red;

class EditDetailsScreen extends StatefulWidget {
  const EditDetailsScreen({super.key});
  @override
  State<EditDetailsScreen> createState() => _EditDetailsScreenState();
}

class _EditDetailsScreenState extends State<EditDetailsScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _budgetCtrl   = TextEditingController(text: '5000');
  String _currency    = '₪ שקל ישראלי';
  bool _obscurePass   = true;
  bool _isLoading     = true;

  final List<String> _currencies = ['₪ שקל ישראלי', '\$ דולר אמריקאי', '€ יורו'];

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'default_user';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _nameCtrl.text = data['name'] ?? '';
        _emailCtrl.text = data['email'] ?? '';
        _budgetCtrl.text = (data['budget'] ?? '5000').toString();
        if (data['currency'] != null && _currencies.contains(data['currency'])) {
          _currency = data['currency'];
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).set({
        'name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'budget': double.tryParse(_budgetCtrl.text) ?? 5000,
        'currency': _currency,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (_passCtrl.text.isNotEmpty && FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.currentUser!.updatePassword(_passCtrl.text);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('הפרופיל עודכן בהצלחה ✓')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('שגיאה בעדכון הפרופיל: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('עריכת פרופיל',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: kBlue))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: const BoxDecoration(color: kBlue, shape: BoxShape.circle),
                        child: const Icon(Icons.person, color: Colors.white, size: 40),
                      ),
                      Container(
                        width: 26, height: 26,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: kBlue, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('שנה תמונה',
                      style: TextStyle(fontSize: 12, color: kBlue)),
                  const SizedBox(height: 24),

                  // Name
                  _profileField('שם מלא', _nameCtrl, Icons.person_outline,
                      validator: (v) => (v == null || v.isEmpty) ? 'שדה חובה' : null),
                  const SizedBox(height: 14),

                  // Email
                  _profileField('אימייל', _emailCtrl, Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'שדה חובה';
                        if (!v.contains('@')) return 'אימייל לא תקין';
                        return null;
                      }),
                  const SizedBox(height: 14),

                  // Password
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('סיסמה חדשה (אופציונלי)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: const TextStyle(color: kGray, fontSize: 13),
                            prefixIcon: const Icon(Icons.lock_outline, color: kBlue, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility,
                                  color: kGray, size: 20),
                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                            ),
                            filled: true, fillColor: kFieldBg,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kBlue)),
                          ),
                          validator: (v) {
                            if (v != null && v.isNotEmpty && v.length < 6) {
                              return 'הסיסמה חייבת להכיל לפחות 6 תווים';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Currency
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('מטבע',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _currency,
                          decoration: InputDecoration(
                            filled: true, fillColor: kFieldBg,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kBlue)),
                            prefixIcon: const Icon(Icons.currency_exchange, color: kBlue, size: 20),
                          ),
                          items: _currencies.map((c) =>
                              DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (v) => setState(() => _currency = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Monthly budget
                  _profileField('תקציב חודשי (₪)', _budgetCtrl, Icons.account_balance_wallet_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'שדה חובה';
                        if (double.tryParse(v) == null) return 'מספר לא תקין';
                        return null;
                      }),
                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('שמור שינויים',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ביטול', style: TextStyle(color: kBlue, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _profileField(String label, TextEditingController ctrl, IconData icon,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            textDirection: TextDirection.rtl,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: kBlue, size: 20),
              filled: true, fillColor: kFieldBg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBlue)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kRed)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kRed)),
            ),
          ),
        ],
      ),
    );
  }
}
