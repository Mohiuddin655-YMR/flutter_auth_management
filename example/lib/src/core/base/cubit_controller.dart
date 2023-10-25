import 'package:flutter_andomie/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CubitController<T extends Entity> extends Cubit<Response<T>> {
  CubitController() : super(Response<T>());
}
