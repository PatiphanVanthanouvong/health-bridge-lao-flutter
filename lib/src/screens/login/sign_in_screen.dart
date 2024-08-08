import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:heathbridge_lao/package.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  String? _errorMessage;

  bool _validatePhoneNumber(String phone) {
    // Lao phone numbers: +856 20 followed by 8 digits
    final RegExp phoneRegExp = RegExp(r'^\+85620\d{8}$');
    return phoneRegExp.hasMatch(phone);
  }

  Future<void> _signInWithPhoneNumber() async {
    if (_formKey.currentState!.validate()) {
      final phoneNumber = _phoneController.text.trim();
      String formattedPhoneNumber = '+85620$phoneNumber';

      if (!_validatePhoneNumber(formattedPhoneNumber)) {
        log("Invalid phone number format.");
        setState(() {
          _errorMessage =
              "ກະລຸນາໃສ່ຮູບເບບເບີໂທຂອງທ່ານໃຫ້ຖືກຕ້ອງ (+85620 XXXXXXXX).";
        });
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      bool canLogin = await userProvider.userCanLogin(formattedPhoneNumber);

      if (!canLogin) {
        setState(() {
          _errorMessage = "ບໍ່ພົບເບີໂທດັ່ງກ່າວໃນລະບົບ ຫຼືບັນຊີຖືກລ໋ອກ.";
        });
        return;
      }
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: formattedPhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) {
            log(credential.toString());
            AwesomeDialog(context: context).show();
          },
          verificationFailed: (FirebaseAuthException e) {
            log("Verification failed: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("ການຢືນຢັນຜິດພາດ: ${e.message}")),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            context.push("/otp/$verificationId");
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } catch (e) {
        log("Error during phone number verification: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ພົບບັນຫາໃນການຢືນຢັນເບີໂທລະສັບ: $e")),
        );
      }
    }
  }

  Future<void> _loginAnonymously() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAnonymous', true);
    context.push("/controller_page");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Back',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                const Text(
                  'ເຂົ້າສູ່ລະບົບ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/lao_flag.png',
                        width: 24,
                      ),
                      const SizedBox(width: 5),
                      const Text('+856 20'),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            hintText: 'XXXXXXXX',
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'ກະລຸນາໃສ່ເບີໂທຂອງທ່ານ';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signInWithPhoneNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ConstantColor.colorMain,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'ເຂົ້າສູ່ລະບົບ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('ຫຼື'),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: TextButton(
                    onPressed: _loginAnonymously,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: ConstantColor.colorMain),
                    ),
                    child: const Text(
                      'ເຂົ້າສູ່ລະບົບເເບບບໍ່ມີບັນຊີ',
                      style: TextStyle(color: ConstantColor.colorMain),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("ຍັງບໍ່ມີບັນຊີຜູ້ໃຊ້?"),
                      TextButton(
                        onPressed: () {
                          context.push("/signup");
                        },
                        child: const Text(
                          "ສະໝັກບັນຊີ",
                          style: TextStyle(
                            color: ConstantColor.colorMain,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
