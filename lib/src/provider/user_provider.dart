import 'dart:developer';

import 'package:heathbridge_lao/package.dart';

class UserProvider extends ChangeNotifier {
  final List<UserModel> _userModel = [];
  bool isAddUser = false;

  List<UserModel> get userModel => _userModel;
  Future<bool> userCanLogin(String phoneNumber) async {
    final HasuraConnect connection = HasuraHelper.hasuraHelper;
    const String checkUserQuery = """
      query checkUserCanLogin(\$tel: String!) {
        users(where: {tel: {_eq: \$tel}}) {
          user_id
          status
        }
      }
    """;

    try {
      final response = await connection.query(checkUserQuery, variables: {
        "tel": phoneNumber,
      });

      log("Query response: $response");

      if (response['data'] == null || response['data']['users'].isEmpty) {
        log("No users found with the phone number: $phoneNumber");
        return false;
      }

      final user = response['data']['users'][0];
      if (user['status'] == 0) {
        log("User with phone number $phoneNumber has status 0 and cannot login.");
        return false;
      }

      log("User found: ${user['user_id']} with status ${user['status']}");
      return true;
    } catch (e) {
      log("Error checking user existence and status: $e");
      return false;
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    final HasuraConnect connection = HasuraHelper.hasuraHelper;
    const String updateUserMutation = """
      mutation updateUser(\$userId: uuid!, \$firstname: String!, \$lastname: String!, \$tel: String!, \$email: String!) {
        update_users(where: {user_id: {_eq: \$userId}}, _set: {firstname: \$firstname, lastname: \$lastname, tel: \$tel, email: \$email}) {
          affected_rows
        }
      }
    """;

    try {
      await connection.mutation(updateUserMutation, variables: {
        "userId": updatedUser.userId,
        "firstname": updatedUser.firstname,
        "lastname": updatedUser.lastname,
        "tel": updatedUser.tel,
        "email": updatedUser.email,
      });

      // Update _userModel list with the updated user
      int index =
          _userModel.indexWhere((user) => user.userId == updatedUser.userId);
      if (index != -1) {
        _userModel[index] = updatedUser;
      }

      notifyListeners();
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  Future<String> getFID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('fid') ?? "";
  }

  Future<String> getUID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid') ?? "";
  }

  Future<void> storeFID(String fid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fid', fid);
  }

  Future<void> storeUID(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
  }

  Future<void> clearUID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
  }

  Future<void> addUserHasura(UserModel user, String firebaseId) async {
    isAddUser = true;
    notifyListeners();
    try {
      await _addUser(user, firebaseId);
      debugPrint("Success adding user to Hasura.");
    } catch (e) {
      debugPrint(e.toString());
    }
    isAddUser = false;
    notifyListeners();
  }

  Future<void> _addUser(UserModel user, String firebaseId) async {
    final HasuraConnect connection = HasuraHelper.hasuraHelper;
    const String addUserMutation = """
      mutation addUser(\$firstname: String!, \$lastname: String!, \$gender: String!, \$tel: String!, \$email: String!, \$status: Int!, \$user_type: String!, \$firebaseId: String!) {
        insert_users(objects: {firstname: \$firstname, lastname: \$lastname, gender: \$gender, tel: \$tel, email: \$email, status: \$status, user_type: \$user_type, firebase_id: \$firebaseId}) {
          affected_rows
        }
      }
    """;

    try {
      await connection.mutation(addUserMutation, variables: {
        "firstname": user.firstname,
        "lastname": user.lastname,
        "gender": user.gender,
        "tel": user.tel,
        "email": user.email,
        "status": 1, // Adjust as per your requirement
        "user_type": "user", // Adjust as per your requirement
        "firebaseId": firebaseId,
      });

      _userModel.add(user); // Add new user to _userModel list
      notifyListeners();
    } catch (e) {
      log("Error adding user: $e");
      rethrow; // Rethrow the error to handle it where addUserHasura is called
    }
  }

  Future<void> fetchUser(String firebaseId) async {
    final HasuraConnect connection = HasuraHelper.hasuraHelper;
    const String fetchUserQuery = """
      query fetchLoggedInUser(\$firebaseId: String!) {
        users(where: {firebase_id: {_eq: \$firebaseId}}) {
          user_id
          tel
          firstname
          lastname
          gender
          email
          firebase_id
        }
      }
    """;

    try {
      final response = await connection.query(fetchUserQuery, variables: {
        "firebaseId": firebaseId,
      });

      if (response['data']['users'].isNotEmpty) {
        final userData = response['data']['users'][0];
        _userModel.clear(); // Clear existing users
        _userModel.add(UserModel(
          userId: userData['user_id'],
          tel: userData['tel'],
          firstname: userData['firstname'],
          lastname: userData['lastname'],
          gender: userData['gender'],
          email: userData['email'],
          firebaseId: userData['firebase_id'],
        ));

        await storeUID(userData['user_id']); // Store uid in SharedPreferences
        await storeFID(
            userData['firebase_id']); // Store fid in SharedPreferences
        notifyListeners();
      } else {
        print("No user found with firebaseId: $firebaseId");
      }
    } catch (e) {
      log("Error fetching user: $e");
    }
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAnonymous', false);
    await prefs.remove('uid');
    await prefs.remove('fid');

    _userModel.clear(); // Clear the user list
    notifyListeners(); // Notify listeners to update UI
  }
}
