import 'package:flutter/foundation.dart';
import '../models/event.dart';

class EventDetailViewModel extends ChangeNotifier {
  final Event _event;
  bool _isLoading = false;

  EventDetailViewModel({required Event event}) : _event = event;

  Event get event => _event;
  bool get isLoading => _isLoading;

  bool get hasImage => _event.imageUrl != null && _event.imageUrl!.isNotEmpty;
  bool get hasTicketUrl => _event.url != null && _event.url!.isNotEmpty;
}
