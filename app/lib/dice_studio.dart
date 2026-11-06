import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Companion/domain/gateways/die_gateways.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/die_use_cases.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_library_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_picker_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';

DieStudioCubit? _buildStudio() {
  if (!getIt.isRegistered<DieLibraryGateway>()) return null;
  final library = getIt<DieLibraryGateway>();
  return DieStudioCubit(
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

class DieStudioHost extends StatefulWidget {
  const DieStudioHost({super.key, required this.child});
  final Widget child;

  @override
  State<DieStudioHost> createState() => _DieStudioHostState();
}

class _DieStudioHostState extends State<DieStudioHost> {
  late final DieStudioCubit? cubit = _buildStudio();

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

Future<DieDesign?> pickDesignFromLibrary(BuildContext context) async {
  final cubit = _buildStudio();
  if (cubit == null) return null;
  final spec = await pickLibraryDie(context, cubit);
  await cubit.close();
  return spec?.design;
}
