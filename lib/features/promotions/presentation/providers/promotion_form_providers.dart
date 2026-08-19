import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/models/promotion.dart';
import 'promotion_providers.dart';

final selectedProductIdProvider = StateProvider<String?>((ref) => null);
final estimatedDemandProvider = StateProvider<String>((ref) => '');
final competitorNameProvider = StateProvider<String>((ref) => '');
final competitorPriceProvider = StateProvider<String>((ref) => '');
final competitorNotesProvider = StateProvider<String>((ref) => '');

final createPromotionControllerProvider = StateNotifierProvider<CreatePromotionController, AsyncValue<Promotion?>>(
  (ref) => CreatePromotionController(ref),
);

class CreatePromotionController extends StateNotifier<AsyncValue<Promotion?>> {
  final Ref _ref;
  CreatePromotionController(this._ref) : super(const AsyncData(null));

  Future<void> submit({required String productName}) async {
    state = const AsyncLoading();
    try {
      final productId = _ref.read(selectedProductIdProvider);
      final demandStr = _ref.read(estimatedDemandProvider);
      final compName = _ref.read(competitorNameProvider);
      final compPriceStr = _ref.read(competitorPriceProvider);
      final compNotes = _ref.read(competitorNotesProvider);

      if (productId == null) throw const AppFailure('Please select a product.');
      if (demandStr.isEmpty) throw const AppFailure('Please enter estimated demand.');
      
      final demand = int.tryParse(demandStr);
      if (demand == null) throw const AppFailure('Estimated demand must be a number.');

      double? compPrice;
      if (compPriceStr.isNotEmpty) {
        compPrice = double.tryParse(compPriceStr);
        if (compPrice == null) throw const AppFailure('Competitor price must be a number.');
      }

      final promo = Promotion(
        id: '',
        productName: productName,
        productId: productId,
        estimatedDemand: demand,
        competitorProductName: compName.isEmpty ? null : compName,
        competitorPrice: compPrice,
        competitorNotes: compNotes.isEmpty ? null : compNotes,
      );

      final repo = _ref.read(promotionRepositoryProvider);
      final created = await repo.createPromotion(promo);
      
      state = AsyncData(created);
      _ref.invalidate(promotionsProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
