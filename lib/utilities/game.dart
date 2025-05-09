import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class Game {
  Network network = Network();

  Future<List<dynamic>> getGame(String gameId, String gameDate) async {
    // Create the query parameters map
    Map<String, String> queryParams = {'gameId': gameId, 'date': gameDate};

    // Create the URL with query parameters
    var url = Uri.http(
      kFlaskUrl,
      '/games/scoreboard',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    List<dynamic> game = jsonData;
    return game;
  }
}
