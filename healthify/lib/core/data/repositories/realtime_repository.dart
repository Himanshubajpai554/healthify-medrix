import '../../models/domain_event.dart';

/// Abstract contract for Realtime subscription event streams
abstract class RealtimeRepository {
  void subscribe(String channel);
  void unsubscribe(String channel);
  Stream<DomainEvent> get eventStream;
}
