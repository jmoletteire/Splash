import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class AwardsNetworkHelper {
  Network network = Network();

  Future<Map<String, dynamic>> getAwards(String season) async {
    // Create the query parameters map
    Map<String, String> queryParams = {'season': season};

    // Create the URL with query parameters
    var url = Uri.http(
      kFlaskUrl,
      '/get_awards',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    Map<String, dynamic> draft = jsonData;
    return draft;
  }

  Future<List> getAwardsByAward(String award) async {
    // Create the query parameters map
    Map<String, String> queryParams = {"award": award};

    // Create the URL with query parameters
    var url = Uri.http(
      kFlaskUrl,
      '/get_awards/by_award',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    List awards = jsonData;
    return awards;
  }
}
