import 'dart:developer';

import 'package:heathbridge_lao/bottom_bar.dart';
import 'package:heathbridge_lao/package.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class OtpScreen extends StatefulWidget {
  final UserModel user;
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.user,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ການຢືນຢັນ OTP",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isAddUser) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 70),
                const Center(
                  child: Text("ການຢືນຢັນລະຫັດ OTP",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
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
                              _verifyOtp(context);
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _verifyOtp(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blue,
                    ),
                    child: const Text("ຢືນຢັນ",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _verifyOtp(BuildContext context) async {
    String otpCode =
        _otpControllers.map((controller) => controller.text).join();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otpCode,
    );
    debugPrint(otpCode);
    try {
      await auth.signInWithCredential(credential);

      // Use provider to manage user addition
      await context
          .read<UserProvider>()
          .addUserHasura(widget.user, auth.currentUser!.uid);
      await context.read<UserProvider>().fetchUser(auth.currentUser!.uid);
      _showSuccessDialog(context);
    } catch (e) {
      _showErrorDialog(context, e.toString());
      debugPrint("Error: $e");
    }
  }

  void _showSuccessDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Success',
      desc: 'OTP verification successful!',
      autoDismiss: true,
      onDismissCallback: (type) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ControllerPage()),
        );
      },
      btnOkOnPress: () {},
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
}
