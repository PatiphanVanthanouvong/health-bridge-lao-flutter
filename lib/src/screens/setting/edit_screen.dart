import 'package:heathbridge_lao/package.dart'; // Adjust this import as per your project structure
import 'package:awesome_dialog/awesome_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String uid = "";
  bool isEditable = false;

  @override
  void initState() {
    super.initState();
    // Fetch user data and populate controllers
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userModelList = userProvider.userModel;

    // Assuming editing the first user in the list
    final userModel = userModelList.isNotEmpty ? userModelList[0] : UserModel();
    uid = userModel.userId!;
    _firstNameController.text = userModel.firstname ?? '';
    _lastNameController.text = userModel.lastname ?? '';
    _telController.text = userModel.tel ?? '';
    _emailController.text = userModel.email ?? '';
  }

  void _toggleEdit() {
    setState(() {
      isEditable = !isEditable;
    });
  }

  void _saveChanges() {
    final updatedUser = UserModel(
      userId: uid,
      firstname: _firstNameController.text.trim(),
      lastname: _lastNameController.text.trim(),
      tel: _telController.text.trim(),
      email: _emailController.text.trim(),
    );

    print(updatedUser.email);
    print(updatedUser.firstname);
    // Update provider with the new user data
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUser(updatedUser);

    // Show success dialog or navigate back
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'ສຳ​ເລັດ​ແລ້ວ',
      desc: 'ຂໍ​ຂອບ​ໃຈ​',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        Navigator.pop(context); // Navigate back
      },
    ).show();
  }

  void _cancelChanges() {
    // Reset the text fields to the original values
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userModelList = userProvider.userModel;
    final userModel = userModelList.isNotEmpty ? userModelList[0] : UserModel();
    _firstNameController.text = userModel.firstname ?? '';
    _lastNameController.text = userModel.lastname ?? '';
    // _telController.text = userModel.tel ?? '';
    _emailController.text = userModel.email ?? '';

    setState(() {
      isEditable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        foregroundColor: Colors.white,
        backgroundColor: ConstantColor.colorMain,
        centerTitle: true,
        title: const Text(
          "ເເກ້ໄຂໜ້າຜູ້ໃຊ້",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Form(
                // key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ຊື່ຜູ້ໃຊ້"),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _firstNameController,
                      enabled: isEditable,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(fontSize: 15),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: " ",
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text("ນາມສະກຸນ"),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _lastNameController,
                      enabled: isEditable,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(fontSize: 15),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: " ",
                        prefixIcon: const Icon(
                          Icons.people,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text("ອີເມວ"),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _emailController,
                      enabled: isEditable,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.mail,
                          color: Colors.black,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(fontSize: 15),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: " ",
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("ເບີໂທ"),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _telController,
                      enabled: false,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Colors.black,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: " ",
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (isEditable)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 150, // specify the width you want
                            child: AnimatedButton(
                              height: 50,
                              isFixedHeight: false,
                              buttonTextStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              text: 'Save',
                              color: ConstantColor.colorMain,
                              pressEvent: _saveChanges,
                            ),
                          ),
                          SizedBox(
                            width: 150, // specify the width you want
                            child: AnimatedButton(
                              height: 50,
                              isFixedHeight: false,
                              buttonTextStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              text: 'Cancel',
                              color: Colors.red,
                              pressEvent: _cancelChanges,
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedButton(
                          height: 50,
                          isFixedHeight: false,
                          buttonTextStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          text: 'ເເກ້ໄຂ',
                          color: ConstantColor.colorMain,
                          pressEvent: _toggleEdit,
                        ),
                      ),
                    const SizedBox(height: 15),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: AnimatedButton(
                    //     height: 50,
                    //     isFixedHeight: false,
                    //     buttonTextStyle: const TextStyle(
                    //       fontSize: 14,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w800,
                    //     ),
                    //     borderRadius: BorderRadius.circular(15),
                    //     text: 'ປິດໃຊ້ງານບັນຊີ',
                    //     color: ConstantColor.colorMain,
                    //     pressEvent: _deactivateAccount,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
