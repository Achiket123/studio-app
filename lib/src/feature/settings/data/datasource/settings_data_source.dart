import 'dart:convert';

import 'package:flutter_riverpod_base/src/commons/usecases/use_case.dart';
import 'package:flutter_riverpod_base/src/core/core.dart';
import 'package:flutter_riverpod_base/src/core/exceptions.dart';
import 'package:flutter_riverpod_base/src/core/models/user_model.dart';
import 'package:flutter_riverpod_base/src/core/user.dart';
import 'package:flutter_riverpod_base/src/res/strings.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

abstract class SettingsDataSource {
  FutureEither<User> updateData(UpdateParams params);
  FutureEitherVoid deleteAccount();
}

class SettingsDataSourceImpl implements SettingsDataSource {
  final http.Client client;

  SettingsDataSourceImpl({required this.client});
  @override
  FutureEither<User> updateData(UpdateParams params) async {
    // print(params.toMap());
    try {
      final uuid = user.uuid;
      final response = await client.post(
          Uri.parse('${AppRequestUrl.baseUrl}${AppRequestUrl.update}/$uuid'),
          headers: {'content-type': 'application/json'},
          body: jsonEncode(params.toMap()));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        user = User.fromMap(data);
        return Right(user);
      } else {
        throw ApiException(message: response.body);
      }
    } on ApiException catch (e) {
      // print(e);
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  FutureEitherVoid deleteAccount() async {
    try {
      final response = await client.delete(Uri.parse(
          '${AppRequestUrl.baseUrl}${AppRequestUrl.delete}/${user.uuid}'));
      if (response.statusCode == 200) {
        print('Account deleted');
        return const Right(null);
      } else {
        throw ApiException(message: response.body);
      }
    } on ApiException catch (e) {
      print(e.message);
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
