// import ...

// class UserRepository extends GetxController {
//   static UserRepository get instance => Get.find();

//   final _db = FirebaseFirestore.instance;

//   Future<void> createUser(UserModel user) async {
//     await _db.collection("Users").add(user.toJson()).whenComplete(
//       () => Get.snackbar(
//         "Success",
//         "You account has been created.",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green.withOpacity(0.1),
//         colorText: Colors.green,
//       ),
//     ).catchError((error, stackTrace) {
//       Get.snackbar(
//         "Error",
//         "Something went wrong. Try again",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.redAccent.withOpacity(0.1),
//         colorText: Colors.red,
//       );
//       print(error.toString());
//     });
//   }
// }