import 'package:flutter/material.dart';

import '../models.dart';
import 'interactive_screen.dart';
import 'lab_protocol_screen.dart';
import 'test_screen.dart';
import 'theory_screen.dart';
import 'virtual_lab_screen.dart';

/// Bosqich kalitiga qarab kerakli ekranni ochadi.
Future<void> openStage(
  BuildContext context,
  LearningModule module,
  String stage,
) async {
  Widget page;
  switch (stage) {
    case 'theory':
      page = TheoryScreen(module: module);
      break;
    case 'interactive':
      page = InteractiveScreen(module: module);
      break;
    case 'vlab':
      page = VirtualLabScreen(module: module);
      break;
    case 'protocol':
      page = LabProtocolScreen(module: module);
      break;
    case 'test':
      page = TestScreen(module: module);
      break;
    default:
      page = TheoryScreen(module: module);
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => page),
  );
}
