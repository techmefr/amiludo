import 'package:flutter/material.dart';

class ToolTab {
  const ToolTab({required this.id, required this.label, this.icon});
  final String id, label;
  final IconData? icon;
}

class ToolTabs {
  const ToolTabs({
    required this.items,
    required this.current,
    required this.onSelect,
    required this.label,
  });
  final List<ToolTab> items;
  final int current;
  final ValueChanged<int> onSelect;
  final String label;
}

class ToolBarController extends ChangeNotifier {
  ToolTabs? tabs;
  List<Widget> actions = const [];
  Object? _owner;
  bool _disposed = false;

  void claim(Object owner, ToolTabs? next, List<Widget> nextActions) {
    if (_disposed) return;
    _owner = owner;
    tabs = next;
    actions = nextActions;
    notifyListeners();
  }

  void release(Object owner) {
    if (_disposed || _owner != owner) return;
    _owner = null;
    tabs = null;
    actions = const [];
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class ToolBarScope extends InheritedNotifier<ToolBarController> {
  const ToolBarScope({
    super.key,
    required ToolBarController controller,
    required super.child,
  }) : super(notifier: controller);

  static ToolBarController? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ToolBarScope>()?.notifier;
}

class ToolBarHost extends StatefulWidget {
  const ToolBarHost({super.key, required this.child});
  final Widget child;

  @override
  State<ToolBarHost> createState() => _ToolBarHostState();
}

class _ToolBarHostState extends State<ToolBarHost> {
  final controller = ToolBarController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ToolBarScope(controller: controller, child: widget.child);
}

class TopBarSlot extends StatefulWidget {
  const TopBarSlot({
    super.key,
    this.tabs,
    this.actions = const [],
    this.fallback,
  });
  final ToolTabs? tabs;
  final List<Widget> actions;
  final Widget? fallback;

  @override
  State<TopBarSlot> createState() => _TopBarSlotState();
}

class _TopBarSlotState extends State<TopBarSlot> {
  ToolBarController? controller;
  bool claimed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = ToolBarScope.maybeOf(context);
    _sync();
  }

  @override
  void didUpdateWidget(TopBarSlot old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final host = controller;
    if (host == null) return;
    final active = TickerMode.valuesOf(context).enabled;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (active) {
        claimed = true;
        host.claim(this, widget.tabs, widget.actions);
      } else if (claimed) {
        claimed = false;
        host.release(this);
      }
    });
  }

  @override
  void dispose() {
    final host = controller;
    if (host != null && claimed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => host.release(this));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => controller == null
      ? (widget.fallback ?? const SizedBox.shrink())
      : const SizedBox.shrink();
}
