import 'package:flutter/material.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

import 'constants.dart';

/// Used to store game dates for CalendarDatePicker
/// Allows us to grey-out any dates without games

class DatesProvider with ChangeNotifier {
  Network network = Network();
  Set<String> _dates = {};

  Set<String> get dates => _dates;

  Future<Set<String>> fetchDates() async {
    var url = Uri.http(
      kFlaskUrl,
      '/games/all-game-dates',
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    List<String> datesList = List<String>.from(jsonData);
    _dates = datesList.toSet();
    notifyListeners();
    return _dates;
  }
}
