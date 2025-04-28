import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class TeamPlayers {
  Network network = Network();

  Future<List> getTeamPlayers(String teamId) async {
    // Create the query parameters map
    Map<String, String> queryParams = {'teamId': teamId};

    // Create the URL with query parameters
    var url = Uri.http(
      kFlaskUrl,
      '/team/roster/player-stats',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    List players = jsonData;
    return players;
  }
}
