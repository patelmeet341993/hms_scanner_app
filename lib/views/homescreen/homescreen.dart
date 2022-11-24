import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hms_models/hms_models.dart';
import 'package:provider/provider.dart';
import 'package:scanner_app/configs/app_theme.dart';
import 'package:scanner_app/views/homescreen/scanner_screen.dart';

import '../../controllers/authentication_controller.dart';
import '../../providers/admin_user_provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/HomeScreen";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ThemeData themeData;

  Future<void> scanORCode() async {
    dynamic value = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
    MyPrint.printOnConsole("Scanner Response:$value");

    if(value is String && value.isNotEmpty) {
      MyToast.showSuccess(context: context, msg: "Scan Successful",);

      updateScannerData(value);
    }
  }

  Future<void> updateScannerData(String data) async {
    try {
      dynamic decodedValue = jsonDecode(data);

      if(decodedValue is Map) {
        AdminUserProvider adminUserProvider = Provider.of<AdminUserProvider>(context, listen: false);
        AdminUserModel? adminUserModel = adminUserProvider.getAdminUserModel();
        if(adminUserModel != null) {
          FirebaseNodes.adminUserDocumentReference(userId: adminUserModel.id).set({"scannerData" : decodedValue}, SetOptions(merge: true,));
        }
      }
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in HomeScreen.updateScannerData():$e");
      MyPrint.printOnConsole(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [
          IconButton(
            onPressed: () {
              AuthenticationController().logout(context: context);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: double.maxFinite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                Consumer<AdminUserProvider>(
                  builder: (BuildContext context, AdminUserProvider adminUserProvider, Widget? child) {
                    AdminUserModel? adminUserModel = adminUserProvider.getAdminUserModel();
                    if(adminUserModel == null) {
                      return const Text("Not Logged in");
                    }

                    return getLoggdInUserCard(adminUserModel);
                  },
                ),
                const SizedBox(height: 20,),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              scanORCode();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: themeData.colorScheme.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "Scan QR",
                style: AppTheme.getTextStyle(
                  themeData.textTheme.caption!,
                  color: themeData.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
           const Expanded(
            child: SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget getLoggdInUserCard(AdminUserModel? adminUserModel) {
    if(adminUserModel == null) {
      return const SizedBox();
    }

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: themeData.colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(adminUserModel.name),
        ],
      ),
    );
  }
}
