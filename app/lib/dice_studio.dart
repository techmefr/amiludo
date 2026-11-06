import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Companion/domain/gateways/die_gateways.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/die_use_cases.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_library_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';

class DieStudioHost extends StatefulWidget {
  const DieStudioHost({super.key, required this.child});
  final Widget child;

  @override
  State<DieStudioHost> createState() => _DieStudioHostState();
}

class _DieStudioHostState extends State<DieStudioHost> {
  DieStudioCubit? cubit;

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<DieLibraryGateway>()) {
      final library = getIt<DieLibraryGateway>();
      cubit = DieStudioCubit(
        DieStudioActions(
          save: getIt<SaveDieUseCase>(),
          remove: getIt<RemoveDieUseCase>(),
          duplicate: getIt<DuplicateDieUseCase>(),
          readImage: getIt<ReadDieImageUseCase>(),
          export: getIt<ExportDiceUseCase>(),
          previewImport: getIt<PreviewDiceImportUseCase>(),
          import: getIt<ImportDiceUseCase>(),
        ),
        library.current,
        library.changes,
      );
    }
  }

  @override
  void dispose() {
    cubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = cubit;
    return c == null ? widget.child : DieStudio(cubit: c, child: widget.child);
  }
}

Widget diceLibraryPage() => const DieStudioHost(child: DieLibraryScreen());
