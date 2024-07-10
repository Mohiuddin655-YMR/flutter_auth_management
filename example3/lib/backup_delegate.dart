import 'dart:developer';

import 'package:auth_management/core.dart';

import 'user_model.dart';

class UserBackupDelegate extends BackupDelegate<UserModel> {
  @override
  Future<UserModel?> get(String id) async {
    // fetch authorized user data from remote server
    log("Authorized user id : $id");
    return null;
  }

  @override
  Future<void> create(UserModel data) async {
    // Store authorized user data in remote server
    log("Authorized user data : $data");
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    // Update authorized user data in remote server
    log("Authorized user data : $data");
  }

  @override
  Future<void> delete(String id) async {
    // Clear unauthorized user data from remote server
    log("Unauthorized user id : $id");
  }

  @override
  UserModel build(Map<String, dynamic> source) => UserModel.from(source);
}
