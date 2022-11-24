import 'package:flutter/foundation.dart';
import 'package:hms_models/models/admin_user/admin_user_model.dart';

class AdminUserProvider extends ChangeNotifier {
  AdminUserModel? _adminUserModel;

  AdminUserModel? getAdminUserModel() {
    if(_adminUserModel != null) {
      return AdminUserModel.fromMap(_adminUserModel!.toMap());
    }
    else {
      return null;
    }
  }

  void setAdminUserModel(AdminUserModel? adminUserModel, {bool isNotify = true}) {
    if(adminUserModel != null) {
      if(_adminUserModel != null) {
        _adminUserModel!.updateFromMap(adminUserModel.toMap());
      }
      else {
        _adminUserModel = AdminUserModel.fromMap(adminUserModel.toMap());
      }
    }
    else {
      _adminUserModel = null;
    }
    if(isNotify) {
      notifyListeners();
    }
  }
}