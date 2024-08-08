// ignore_for_file: use_build_context_synchronously

import 'package:heathbridge_lao/bottom_bar.dart';
import 'package:heathbridge_lao/package.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class OTPLogin extends StatefulWidget {
  final String verificationId;

  const OTPLogin({
    super.key,
    required this.verificationId,
  });

  @override
  State<OTPLogin> createState() => _OTPLoginState();
}

class _OTPLoginState extends State<OTPLogin> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void verifyOtp() async {
    String otpCode =
        _otpControllers.map((controller) => controller.text).join();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otpCode,
    );
    debugPrint(otpCode);

    // Show loading dialog
    AwesomeDialog loadingDialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      title: 'Loading',
      desc: 'Please wait',
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
    )..show();

    try {
      await auth.signInWithCredential(credential);

      // Fetch user data
      await context.read<UserProvider>().fetchUser(auth.currentUser!.uid);

      // Close loading dialog
      loadingDialog.dismiss();
      _showSuccessDialog(context);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ControllerPage()),
        );
      }
    } catch (e) {
      loadingDialog.dismiss();
      print("Error: $e");
      _showErrorDialog(context, e.toString());
    }
  }

  void _showSuccessDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Success',
      desc: 'OTP verification successful!',
      btnOkOnPress: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ControllerPage()),
        );
      },
    ).show();
  }

  void _showErrorDialog(BuildContext context, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Verification",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 70),
            const Center(
              child: Text("OTP Verification",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "0",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        counterText: '',
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                      onFieldSubmitted: (value) {
                        if (index == 5) {
                          verifyOtp();
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: verifyOtp,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: ConstantColor.colorMain,
                ),
                child: const Text("Verify",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
