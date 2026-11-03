import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Templates/domain/use_cases/fetch_pack_catalog_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/use_cases/load_bundled_catalog_use_case.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/marketplace_state.dart';

class MarketplaceCubit extends Cubit<MarketplaceState> {
  MarketplaceCubit(this._loadBundledCatalog, this._fetchPackCatalog)
    : super(const MarketplaceState());

  final LoadBundledCatalogUseCase _loadBundledCatalog;
  final FetchPackCatalogUseCase _fetchPackCatalog;

  Future<void> loadBundled() async {
    try {
      final packs = await _loadBundledCatalog();
      emit(MarketplaceState(packs: packs, loading: false));
    } catch (_) {
      emit(
        const MarketplaceState(
          loading: false,
          error: MarketplaceError.unavailable,
        ),
      );
    }
  }

  Future<void> refresh() async {
    emit(
      MarketplaceState(packs: state.packs, loading: true, online: state.online),
    );
    try {
      final packs = await _fetchPackCatalog();
      emit(MarketplaceState(packs: packs, loading: false, online: true));
    } catch (_) {
      emit(
        MarketplaceState(
          packs: state.packs,
          loading: false,
          online: state.online,
          error: MarketplaceError.refreshFailed,
        ),
      );
    }
  }
}
