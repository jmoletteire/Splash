import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class Player {
  Network network = Network();

  Future<Map<String, dynamic>> getPlayer(String personId,
      {String? rosterStatus, String? teamId}) async {
    // Create the query parameters map
    Map<String, String> queryParams = {'person_id': personId};

    // Add optional parameters if provided
    if (rosterStatus != null) {
      queryParams['rosterstatus'] = rosterStatus;
    }
    if (teamId != null) {
      queryParams['teamid'] = teamId;
    }

    // Create the URL with query parameters
    var url = Uri.https(
      kFlaskUrl,
      '/get_player',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    Map<String, dynamic> player = jsonData;
    return player;
  }

  Future<Map<String, dynamic>> getShotChart(String personId, String season) async {
    // Create the query parameters map
    Map<String, String> queryParams = {'person_id': personId, 'season': season};

    // Create the URL with query parameters
    var url = Uri.https(
      kFlaskUrl,
      '/get_player_shot_chart',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    Map<String, dynamic> shotChart = jsonData;
    return shotChart;
  }
}
