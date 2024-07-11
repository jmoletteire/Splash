import 'dart:async';
import 'dart:collection';

class NetworkRequestManager {
  final int maxConcurrentRequests;
  int _activeRequests = 0;
  final Queue<Function> _requestQueue = Queue<Function>();

  NetworkRequestManager({this.maxConcurrentRequests = 30});

  Future<T> performRequest<T>(Future<T> Function() request) {
    final completer = Completer<T>();

    void _processNext() {
      if (_requestQueue.isNotEmpty && _activeRequests < maxConcurrentRequests) {
        final nextRequest = _requestQueue.removeFirst();
        nextRequest();
      }
    }

    void _handleRequest() async {
      _activeRequests++;
      print(_activeRequests);
      try {
        final result = await request();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      } finally {
        _activeRequests--;
        _processNext();
      }
    }

    _requestQueue.add(_handleRequest);
    _processNext();

    return completer.future;
  }
}
