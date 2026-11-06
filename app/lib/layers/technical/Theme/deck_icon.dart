import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

final _icons = <IconData, List<List<dynamic>>>{
  Icons.add: HugeIcons.strokeRoundedAdd01,
  Icons.account_circle_outlined: HugeIcons.strokeRoundedUserCircle,
  Icons.event_outlined: HugeIcons.strokeRoundedCalendar03,
  Icons.add_chart_outlined: HugeIcons.strokeRoundedAbacus,
  Icons.arrow_drop_down: HugeIcons.strokeRoundedArrowDown01,
  Icons.arrow_outward: HugeIcons.strokeRoundedArrowUpRight01,
  Icons.auto_stories_outlined: HugeIcons.strokeRoundedBookOpen01,
  Icons.badge_outlined: HugeIcons.strokeRoundedId,
  Icons.bug_report_outlined: HugeIcons.strokeRoundedBug01,
  Icons.build_outlined: HugeIcons.strokeRoundedWrench01,
  Icons.casino_outlined: HugeIcons.strokeRoundedDices,
  Icons.camera_alt_outlined: HugeIcons.strokeRoundedCamera01,
  Icons.check: HugeIcons.strokeRoundedTick02,
  Icons.chevron_right: HugeIcons.strokeRoundedArrowRight01,
  Icons.add_photo_alternate_outlined: HugeIcons.strokeRoundedImageAdd01,
  Icons.key_outlined: HugeIcons.strokeRoundedKey01,
  Icons.lock_outline: HugeIcons.strokeRoundedLockKey,
  Icons.photo_library_outlined: HugeIcons.strokeRoundedAlbum01,
  Icons.qr_code_2: HugeIcons.strokeRoundedQrCode,
  Icons.remove: HugeIcons.strokeRoundedMinusSign,
  Icons.shelves: HugeIcons.strokeRoundedLibrary,
  Icons.thumb_down_outlined: HugeIcons.strokeRoundedThumbsDown,
  Icons.thumb_up_outlined: HugeIcons.strokeRoundedThumbsUp,
  Icons.people_outline: HugeIcons.strokeRoundedUserMultiple,
  Icons.close: HugeIcons.strokeRoundedCancel01,
  Icons.contrast: HugeIcons.strokeRoundedSun03,
  Icons.copy_outlined: HugeIcons.strokeRoundedCopy01,
  Icons.dashboard_outlined: HugeIcons.strokeRoundedDashboardSquare01,
  Icons.delete_forever_outlined: HugeIcons.strokeRoundedDelete02,
  Icons.delete_outline: HugeIcons.strokeRoundedDelete02,
  Icons.diamond_outlined: HugeIcons.strokeRoundedDiamond,
  Icons.edit_note: HugeIcons.strokeRoundedNoteEdit,
  Icons.edit_outlined: HugeIcons.strokeRoundedEdit02,
  Icons.emoji_events_outlined: HugeIcons.strokeRoundedTrophy,
  Icons.extension_outlined: HugeIcons.strokeRoundedPuzzle,
  Icons.file_download_outlined: HugeIcons.strokeRoundedDownload01,
  Icons.file_open_outlined: HugeIcons.strokeRoundedFolderOpen,
  Icons.flag_outlined: HugeIcons.strokeRoundedFlag01,
  Icons.groups_outlined: HugeIcons.strokeRoundedUserGroup,
  Icons.hexagon_outlined: HugeIcons.strokeRoundedHexagon,
  Icons.history: HugeIcons.strokeRoundedClock01,
  Icons.home_outlined: HugeIcons.strokeRoundedHome01,
  Icons.info_outline: HugeIcons.strokeRoundedInformationCircle,
  Icons.ios_share_outlined: HugeIcons.strokeRoundedShare01,
  Icons.lightbulb_outline: HugeIcons.strokeRoundedBulb,
  Icons.list: HugeIcons.strokeRoundedMenu01,
  Icons.menu_book_outlined: HugeIcons.strokeRoundedBookOpen01,
  Icons.more_horiz: HugeIcons.strokeRoundedMoreHorizontal,
  Icons.numbers: HugeIcons.strokeRoundedHashtag,
  Icons.open_in_new: HugeIcons.strokeRoundedLinkSquare02,
  Icons.pause: HugeIcons.strokeRoundedPause,
  Icons.play_arrow: HugeIcons.strokeRoundedPlay,
  Icons.radar: HugeIcons.strokeRoundedRadar01,
  Icons.redo: HugeIcons.strokeRoundedRedo,
  Icons.refresh: HugeIcons.strokeRoundedRefresh,
  Icons.remove_circle_outline: HugeIcons.strokeRoundedRemoveCircle,
  Icons.restart_alt: HugeIcons.strokeRoundedRefreshCcw,
  Icons.rotate_left: HugeIcons.strokeRoundedRotateLeft01,
  Icons.rotate_right: HugeIcons.strokeRoundedRotateRight01,
  Icons.save_outlined: HugeIcons.strokeRoundedFloppyDisk,
  Icons.search: HugeIcons.strokeRoundedSearch01,
  Icons.share_outlined: HugeIcons.strokeRoundedShare08,
  Icons.shopping_bag_outlined: HugeIcons.strokeRoundedShoppingBag01,
  Icons.skip_next: HugeIcons.strokeRoundedNext,
  Icons.skip_next_outlined: HugeIcons.strokeRoundedNext,
  Icons.south: HugeIcons.strokeRoundedArrowDown01,
  Icons.star: HugeIcons.strokeRoundedStar,
  Icons.star_outline: HugeIcons.strokeRoundedStar,
  Icons.storefront_outlined: HugeIcons.strokeRoundedStore01,
  Icons.style_outlined: HugeIcons.strokeRoundedCards01,
  Icons.swap_vert: HugeIcons.strokeRoundedArrowUpDown,
  Icons.table_restaurant_outlined: HugeIcons.strokeRoundedDiningTable,
  Icons.timer_outlined: HugeIcons.strokeRoundedTimer01,
  Icons.toll_outlined: HugeIcons.strokeRoundedCoins01,
  Icons.touch_app_outlined: HugeIcons.strokeRoundedTouch01,
  Icons.tune: HugeIcons.strokeRoundedSlidersHorizontal,
  Icons.undo: HugeIcons.strokeRoundedUndo,
  Icons.view_module_outlined: HugeIcons.strokeRoundedGridView,
  Icons.visibility_off_outlined: HugeIcons.strokeRoundedEyeOff,
};

class DeckIcon extends StatelessWidget {
  const DeckIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final data = _icons[icon];
    final child = data == null
        ? Icon(icon, size: size, color: color)
        : HugeIcon(
            icon: data,
            size: size ?? theme.size ?? 24,
            color: color ?? theme.color,
            strokeWidth: 1.8,
          );
    return semanticLabel == null
        ? child
        : Semantics(label: semanticLabel, child: child);
  }
}
