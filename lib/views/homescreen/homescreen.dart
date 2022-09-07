import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:scanner_app/utils/logger_service.dart';
import 'package:scanner_app/utils/my_toast.dart';
import 'package:scanner_app/views/homescreen/scanner_screen.dart';

import '../../controllers/authentication_controller.dart';
import '../../models/admin_user_model.dart';
import '../../providers/admin_user_provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/HomeScreen";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Home Screen"),
          actions: [
            IconButton(
              onPressed: () {
                AuthenticationController().logout(context: context);
              },
              icon: Icon(Icons.logout),
            )
          ],
        ),
        body: getBody(),
      ),
    );
  }

  Widget getBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Home Body"),
          SizedBox(height: 20,),
          Consumer<AdminUserProvider>(
            builder: (BuildContext context, AdminUserProvider adminUserProvider, Widget? child) {
              AdminUserModel? adminUserModel = adminUserProvider.getAdminUserModel();
              if(adminUserModel == null) {
                return Text("Not Logged in");
              }
              return Column(
                children: [
                  Text("User Name:${adminUserProvider.getAdminUserModel()!.name}"),
                  Text("User Role:${adminUserProvider.getAdminUserModel()!.role}"),
                ],
              );
            },
          ),
          SizedBox(height: 20,),
          FlatButton(
            onPressed: () async {
              // VisitController().createDummyVisitDataInFirestore();
              // PatientController().createDummyPatientDataInFirestore();

              dynamic value = await Navigator.push(context, MaterialPageRoute(builder: (_) => ScannerScreen()));
              Log().i("Scanner Response:$value");

              MyToast.showSuccess("Got '$value' from Scanner", context);
            },
            child: Text("Create Visit"),
          ),
        ],
      ),
    );
  }
}
