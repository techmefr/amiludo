import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_state.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class WorkspaceGate extends StatelessWidget {
  const WorkspaceGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final status = context.select<WorkspaceCubit, WorkspaceStatus>(
      (cubit) => cubit.state.status,
    );
    return switch (status) {
      WorkspaceStatus.ready => child,
      WorkspaceStatus.loading => Material(
        type: MaterialType.transparency,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                tr(context, 'Ouverture de votre table…', 'Opening your table…'),
              ),
            ],
          ),
        ),
      ),
      WorkspaceStatus.failure => Material(
        type: MaterialType.transparency,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyPanel(
                title: tr(
                  context,
                  'La bibliothèque n’a pas pu être ouverte',
                  'Could not open your library',
                ),
                message: tr(
                  context,
                  'Vos données ne sont pas écrasées. Vérifiez que ce navigateur autorise le stockage local et réessayez.',
                  'Your data has not been overwritten. Check browser storage permissions and retry.',
                ),
                action: FilledButton(
                  onPressed: context.read<WorkspaceCubit>().load,
                  child: Text(tr(context, 'Réessayer', 'Retry')),
                ),
              ),
            ),
          ),
        ),
      ),
    };
  }
}
