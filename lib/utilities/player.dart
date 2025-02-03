import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class Player {
  Network network = Network();

  Future<Map<String, dynamic>> getPlayer(String personId,
      {String? rosterStatus, String? teamId}) async {
    // Create the query parameters map
    Map<String, String> queryParams = {'personId': personId};

    // Add optional parameters if provided
    if (rosterStatus != null) {
      queryParams['rosterStatus'] = rosterStatus;
    }
    if (teamId != null) {
      queryParams['teamId'] = teamId;
    }

    // Create the URL with query parameters
    var url = Uri.http(
      kFlaskUrl,
      '/players',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    try {
      Map<String, dynamic> player = jsonData;
      return player;
    } catch (e) {
      return {'error': 'player not found'};
    }
  }

  Future<Map<String, dynamic>> getShotChart(
      String personId, String season, String seasonType) async {
    // Create the query parameters map
    Map<String, String> queryParams = {
      'personId': personId,
      'season': season,
      'seasonType': seasonType
    };

    // Create the URL with query parameters
    var url = Uri.http(
      kFlaskUrl,
      '/players/stats/shot-chart',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    Map<String, dynamic> shotChart = jsonData;
    return shotChart;
  }
}
