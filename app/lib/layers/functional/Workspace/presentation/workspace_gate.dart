import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_state.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
              Text(context.l10n.workspaceOpeningYourTable),
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
                icon: Icons.error_outline,
                title: context.l10n.workspaceCouldNotOpenYourLibrary,
                message: context.l10n.workspaceYourDataHasNotBeen,
                action: FilledButton(
                  onPressed: context.read<WorkspaceCubit>().load,
                  child: Text(context.l10n.workspaceRetry),
                ),
              ),
            ),
          ),
        ),
      ),
    };
  }
}
