import '../../models/bed_model.dart';

abstract class ICURepository {
  Future<List<ICUUnit>> getICUUnits();
  Future<ICUUnit?> getICUUnitById(String id);
  Future<void> updateICUUnit(ICUUnit unit);
}
