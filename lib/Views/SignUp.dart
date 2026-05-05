import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'MainScreen.dart';

const Color kBlue = Colors.blue;
const Color kGray = Colors.grey;
const Color kFieldBg = Color(0xFFF5F5F5);
const Color kRed = Colors.red;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passCtrl       = TextEditingController();
  final _confirmCtrl    = TextEditingController();
  bool _obscurePass     = true;
  bool _obscureConfirm  = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: 70, height: 70,
                  decoration: const BoxDecoration(color: Color(0xFFE3F2FD), shape: BoxShape.circle),
                  child: const Icon(Icons.person_add_outlined, color: kBlue, size: 34),
                ),
                const SizedBox(height: 12),
                const Text('הרשמה',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('צור חשבון חדש',
                    style: TextStyle(fontSize: 13, color: kGray)),
                const SizedBox(height: 24),

                _buildField('שם מלא', _nameCtrl, Icons.person_outline, 'הזן את שמך המלא',
                    validator: (v) => (v == null || v.isEmpty) ? 'שדה חובה' : null),
                const SizedBox(height: 14),

                _buildField('אימייל', _emailCtrl, Icons.email_outlined, 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'שדה חובה';
                      if (!v.contains('@')) return 'אימייל לא תקין';
                      return null;
                    }),
                const SizedBox(height: 14),

                _buildPasswordField('סיסמה', _passCtrl, _obscurePass,
                        () => setState(() => _obscurePass = !_obscurePass),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'הסיסמה חייבת להכיל לפחות 6 תווים' : null),
                const SizedBox(height: 14),

                _buildPasswordField('אישור סיסמה', _confirmCtrl, _obscureConfirm,
                        () => setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (v) => v != _passCtrl.text ? 'הסיסמאות אינן תואמות' : null),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('הירשם',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('התחבר',
                          style: TextStyle(color: kBlue, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    const Text('?כבר יש לך חשבון',
                        style: TextStyle(color: kGray, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, String hint,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            textDirection: TextDirection.rtl,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: kGray, fontSize: 13),
              prefixIcon: Icon(icon, color: kBlue, size: 20),
              filled: true, fillColor: kFieldBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBlue)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kRed)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kRed)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController ctrl, bool obscure,
      VoidCallback toggle, {String? Function(String?)? validator}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            obscureText: obscure,
            textDirection: TextDirection.ltr,
            validator: validator,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: kGray, fontSize: 13),
              prefixIcon: const Icon(Icons.lock_outline, color: kBlue, size: 20),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: kGray, size: 20),
                onPressed: toggle,
              ),
              filled: true, fillColor: kFieldBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBlue)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kRed)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kRed)),
            ),
          ),
        ],
      ),
    );
  }
}
