import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hms_models/configs/constants.dart';
import 'package:hms_models/configs/typedefs.dart';
import 'package:hms_models/models/admin_user/admin_user_model.dart';
import 'package:hms_models/utils/my_print.dart';
import 'package:hms_models/utils/my_toast.dart';
import 'package:hms_models/utils/parsing_helper.dart';
import 'package:hms_models/utils/shared_pref_manager.dart';
import 'package:provider/provider.dart';

import '../configs/app_strings.dart';
import '../configs/constants.dart';
import '../providers/admin_user_provider.dart';
import '../views/authentication/login_screen.dart';
import '../views/homescreen/homescreen.dart';
import 'navigation_controller.dart';

class AuthenticationController {
  Future<AdminUserModel?> isUserLoggedIn() async {
    AdminUserProvider adminUserProvider = Provider.of<AdminUserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);

    String userJson = await SharedPrefManager().getString(SharePrefrenceKeys.loggedInUser) ?? "";

    AdminUserModel? adminUserModel;

    try {
      dynamic object = jsonDecode(userJson);
      if(object is Map) {
        Map<String, dynamic> map = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(object);
        adminUserModel = AdminUserModel.fromMap(map);
      }
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Decoding User Data From Shared Preference:$e");
      MyPrint.printOnConsole(s);
    }

    if(adminUserModel != null && adminUserModel.id.isNotEmpty) {
      MyFirestoreDocumentSnapshot documentSnapshot = await FirebaseNodes.adminUserDocumentReference(userId: adminUserModel.id).get();

      if(documentSnapshot.exists && (documentSnapshot.data() ?? {}).isNotEmpty) {
        AdminUserModel newModel = AdminUserModel.fromMap(documentSnapshot.data()!);
        if(adminUserModel.username == newModel.username && adminUserModel.password == newModel.password) {
          adminUserProvider.setAdminUserModel(newModel);
          if(adminUserModel != newModel) {
            SharedPrefManager().setString(SharePrefrenceKeys.loggedInUser, jsonEncode(newModel.toMap()));
          }
          return newModel;
        }
        else {
          adminUserProvider.setAdminUserModel(null);
          SharedPrefManager().setString(SharePrefrenceKeys.loggedInUser, "");
          return null;
        }
      }
      else {
        adminUserProvider.setAdminUserModel(null);
        SharedPrefManager().setString(SharePrefrenceKeys.loggedInUser, "");
        return null;
      }
    }
    else {
      adminUserProvider.setAdminUserModel(null);
      SharedPrefManager().setString(SharePrefrenceKeys.loggedInUser, "");
      return null;
    }
  }
  
  Future<bool> loginAdminUserWithUsernameAndPassword({required BuildContext context, required String userName, required String password, List<String> userTypes = AppConstants.userTypesForLogin,}) async {
    bool isLoginSuccess = false;

    if(userName.isEmpty || password.isEmpty) {
      MyToast.showError(context: context, msg: AppStrings.usernameOrPasswordIsEmpty,);
      return isLoginSuccess;
    }

    if(userTypes.isEmpty) {
      userTypes.addAll(AppConstants.userTypesForLogin);
    }

    AdminUserModel? adminUserModel;

    MyFirestoreQuery query = FirebaseNodes.adminUsersCollectionReference.where("username", isEqualTo: userName);
    if(userTypes.isNotEmpty) {
      query = query.where("role", whereIn: userTypes);
    }
    MyFirestoreQuerySnapshot querySnapshot = await query.get();
    if(querySnapshot.docs.isNotEmpty) {
      MyFirestoreQueryDocumentSnapshot docSnapshot = querySnapshot.docs.first;
      if(docSnapshot.data().isNotEmpty) {
        AdminUserModel model = AdminUserModel.fromMap(docSnapshot.data());
        isLoginSuccess = model.username == userName && model.password == password && (userTypes.isNotEmpty ? userTypes.contains(model.role) : true);
        if(isLoginSuccess) {
          adminUserModel = model;
        }
      }
    }
    
    AdminUserProvider adminUserProvider = Provider.of<AdminUserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    adminUserProvider.setAdminUserModel(adminUserModel, isNotify: false);
    SharedPrefManager().setString(SharePrefrenceKeys.loggedInUser, adminUserModel != null ? jsonEncode(adminUserModel.toMap(toJson: true)) : "");

    if(isLoginSuccess) {
      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
    }

    return isLoginSuccess;
  }

  Future<bool> logout({required BuildContext context}) async {
    bool isLoggedOut = false;

    AdminUserProvider adminUserProvider = Provider.of<AdminUserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    adminUserProvider.setAdminUserModel(null, isNotify: false);
    SharedPrefManager().setString(SharePrefrenceKeys.loggedInUser, "");
    isLoggedOut = true;

    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);

    return isLoggedOut;
  }
}