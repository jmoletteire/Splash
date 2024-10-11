import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class TeamPlayers {
  Network network = Network();

  Future<List> getTeamPlayers(String teamId) async {
    // Create the query parameters map
    Map<String, String> queryParams = {'team_id': teamId};

    // Create the URL with query parameters
    var url = Uri.http(
      kFlaskUrl,
      '/get_game/get_team_player_stats',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    List players = jsonData;
    return players;
  }
}
