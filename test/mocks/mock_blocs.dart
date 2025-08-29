import 'package:bloc_test/bloc_test.dart';
import 'package:portion_control/application_services/blocs/menu/menu_bloc.dart';

class MockMenuBloc extends MockBloc<MenuEvent, MenuState> implements MenuBloc {}
