// import 'dart:developer';

// import 'package:heathbridge_lao/package.dart';

// class SetPasswordScreen extends StatefulWidget {
//   const SetPasswordScreen(
//       {super.key,
//       required this.firstname,
//       required this.lastname,
//       required this.email,
//       required this.tel,
//       required this.gender});
//   final String firstname;
//   final String lastname;
//   final String email;
//   final String tel;
//   final String gender;

//   @override
//   State<SetPasswordScreen> createState() => _SetPasswordScreenState();
// }

// class _SetPasswordScreenState extends State<SetPasswordScreen> {
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   bool _obscureText1 = true;
//   bool _obscureText2 = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Row(
//           children: [
//             Text(
//               'Back',
//               style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         automaticallyImplyLeading: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             const Center(
//               child: Text(
//                 'Set password',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 10),
//             const Center(
//               child: Text(
//                 'Set your password',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: _passwordController,
//               obscureText: _obscureText1,
//               decoration: InputDecoration(
//                 hintText: 'Enter Your Password',
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _obscureText1 ? Icons.visibility_off : Icons.visibility,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _obscureText1 = !_obscureText1;
//                     });
//                   },
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _confirmPasswordController,
//               obscureText: _obscureText2,
//               decoration: InputDecoration(
//                 hintText: 'Confirm Password',
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _obscureText2 ? Icons.visibility_off : Icons.visibility,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _obscureText2 = !_obscureText2;
//                     });
//                   },
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               'At least 1 number or a special character',
//               style: TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   final String telNumber = "+856${widget.tel}";
//                   if (_passwordController.text.isNotEmpty &&
//                       _passwordController.text ==
//                           _confirmPasswordController.text) {
//                     UserModel newUser = UserModel(
//                       firstname: widget.firstname,
//                       lastname: widget.lastname,
//                       gender: widget.gender,
//                       tel: widget.tel,
//                       email: widget.email,
//                       // password: _passwordController.text,
//                     );
//                     // print(context.read<UserProvider>().userModel);
//                     await FirebaseAuth.instance.verifyPhoneNumber(
//                       phoneNumber: telNumber,
//                       verificationCompleted: (PhoneAuthCredential credential) {
//                         log(credential.toString());
//                       },
//                       verificationFailed: (FirebaseAuthException e) {
//                         log(e.toString());
//                       },
//                       codeSent: (String verificationId, int? resendToken) {
//                         context.push("/otp/$verificationId");
//                       },
//                       codeAutoRetrievalTimeout: (String verificationId) {},
//                     );
//                     await context.read<UserProvider>().addUser(newUser);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: ConstantColor.colorMain,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text(
//                   'Register',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
