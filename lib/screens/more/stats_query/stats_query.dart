import 'dart:convert';

import '../../../utilities/constants.dart';
import '../../../utilities/nba_api/library/network.dart';

class StatsQuery {
  Network network = Network();

  Future<Map<String, dynamic>> postStatsQuery(
      String selectedSeason, List<Map<String, dynamic>> filters) async {
    // Create the query parameters map
    Map<String, dynamic> queryParams = {
      'season': selectedSeason,
      'stats': filters
    };
    String filtersJson = jsonEncode(queryParams);

    // Create the URL with query parameters
    var url = Uri.http(
      kFlaskUrl,
      '/stats_query',
    );

    // Fetch the data from the network
    dynamic jsonData = await network.postData(url, filtersJson);
    Map<String, dynamic> results = jsonData;
    return results;
  }
}
