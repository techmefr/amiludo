import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Library/domain/entities/barcode_match.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/barcode_lookup_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/import_collection_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/resolve_barcode_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/search_games_online_use_case.dart';

class BarcodeScanCubit extends Cubit<bool> {
  BarcodeScanCubit(this._resolve, this._search, this._import) : super(false);

  final ResolveBarcodeUseCase _resolve;
  final SearchGamesOnlineUseCase _search;
  final ImportCollectionUseCase _import;

  bool get canSearchOnline => _search.available;

  Future<BarcodeMatch?> resolve(String raw) async {
    if (state || !isValidBarcode(barcodeDigits(raw))) return null;
    emit(true);
    try {
      return await _resolve(raw);
    } finally {
      if (!isClosed) emit(false);
    }
  }

  Future<int?> importCollection(String username) async {
    try {
      return await _import(username);
    } on BarcodeLookupFailure {
      return null;
    }
  }

  Future<List<BarcodeProduct>> searchOnline(String name) => _search(name);
}
