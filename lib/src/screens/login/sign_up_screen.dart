import 'package:heathbridge_lao/package.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Step 1

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  String? gender;
  bool isCheckedTermsOfService = false;
  String? verificationId;
  @override
  void initState() {
    _initializeForm();
    super.initState();
  }

  // Validators for each TextFormField (same as before)
  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາໃສ່ຊື່ເຂົ້າຊົມ';
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາໃສ່ນາມສະກຸນ';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາໃສ່ອີເມວ';
    }
    // You can add additional email validation logic here if needed
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາໃສ່ເບີໂທ';
    }
    return null;
  }

  void _initializeForm() {
    firstnameController.text = "ປະຕິພານ"; // Set initial value for Firstname
    lastnameController.text = "ວັນທານຸວົງ"; // Set initial value for Lastname
    emailController.text =
        "patiphanvanthanouvong@gmail.com"; // Set initial value for Email
    telController.text = "78357352"; // Set initial value for Phone Number

    isCheckedTermsOfService =
        true; // Set initial value for Terms of Service checkbox
  }

  Future<void> _verifyPhoneNumber() async {
    String countryCode = '+85620'; // Your default country code
    String phoneNumber =
        telController.text.trim(); // Get the entered phone number

    // Concatenate the country code and phone number
    String formattedPhoneNumber = '$countryCode$phoneNumber';

    verificationCompleted(PhoneAuthCredential phoneAuthCredential) {}

    verificationFailed(FirebaseAuthException authException) {}

    codeSent(String verificationId, int? resendToken) async {
      // Save verificationId for later use
      this.verificationId = verificationId;

      // Navigate to OTP screen
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => OtpScreen(
          verificationId: verificationId,
          user: UserModel(
            firstname: firstnameController.text,
            lastname: lastnameController.text,
            email: emailController.text,
            tel: formattedPhoneNumber, // Use the formatted phone number
            gender: gender,
          ),
        ),
      ));
    }

    codeAutoRetrievalTimeout(String verificationId) {}

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: formattedPhoneNumber, // Use the formatted phone number
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ກັບຄືນ',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            // Step 2: Wrap your form with Form widget
            key: _formKey, // Assign the key property
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'ສະໝັກບັນຊີຜູ້ໃຊ້',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                // First Name TextFormField
                TextFormField(
                  controller: firstnameController,
                  validator: validateFirstName, // Validate function
                  decoration: InputDecoration(
                    hintText: 'ຊື່ເເທ້',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Last Name TextFormField
                TextFormField(
                  controller: lastnameController,
                  validator: validateLastName, // Validate function
                  decoration: InputDecoration(
                    hintText: 'ນາມສະກຸນ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Email TextFormField
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail, // Validate function
                  decoration: InputDecoration(
                    hintText: 'ອີເມວ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Phone Number TextFormField
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
                          controller: telController,
                          keyboardType: TextInputType.phone,
                          validator: validatePhoneNumber, // Validate function
                          decoration: const InputDecoration(
                            hintText: 'XXXXXXXX',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Gender DropdownButtonFormField
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'ເພດ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Male',
                      child: Text('ຊາຍ'),
                    ),
                    DropdownMenuItem(
                      value: 'Female',
                      child: Text('ຍິງ'),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child: Text('ອື່ນໆ'),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                // Terms of Service Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: isCheckedTermsOfService,
                      onChanged: (bool? value) {
                        setState(() {
                          isCheckedTermsOfService = value ?? false;
                        });
                      },
                    ),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          text: 'ໂດຍການທີ່ສະໝັກບັນຊີ, ທ່ານເຫັນດີກັບ ',
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'ເງື່ອນໄຂຂອງການບໍລິການ',
                              style: const TextStyle(
                                color: ConstantColor.colorMain,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Handle Terms of service link tap
                                },
                            ),
                            const TextSpan(
                              text: ' ເເລະ ',
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: 'ກົດໝາຍທາງດ້ານຄວາມປອດໄພ',
                              style: const TextStyle(
                                color: ConstantColor.colorMain,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Handle Privacy policy link tap
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Step 3: Validate the form
                      _verifyPhoneNumber(); // Proceed with verification
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConstantColor.colorMain,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'ຕໍ່ໄປ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                // Already have an account? Sign in Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "ທ່ານມີບັນຊີຢູ່ເເລ້ວ?",
                    ),
                    TextButton(
                      onPressed: () {
                        context.push("/signin");
                      },
                      child: const Text(
                        'ເຂົ້າສູ່ລະບົບດ້ວຍບັນຊີ',
                        style: TextStyle(
                            color: ConstantColor.colorMain,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
