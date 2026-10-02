import 'dart:async';
import '../repositories/realtime_repository.dart';
import '../../models/domain_event.dart';

class MockRealtimeRepository implements RealtimeRepository {
  final StreamController<DomainEvent> _controller = StreamController<DomainEvent>.broadcast();
  final Set<String> _activeChannels = {};

  MockRealtimeRepository();

  @override
  void subscribe(String channel) {
    _activeChannels.add(channel);
  }

  @override
  void unsubscribe(String channel) {
    _activeChannels.remove(channel);
  }

  @override
  Stream<DomainEvent> get eventStream => _controller.stream;

  void emitMockEvent(DomainEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
