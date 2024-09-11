import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class PlayoffsNetworkHelper {
  Network network = Network();

  Future<Map<String, dynamic>> getPlayoffs(String season) async {
    // Create the query parameters map
    Map<String, String> queryParams = {'season': season};

    // Create the URL with query parameters
    var url = Uri.http(
      kFlaskUrl,
      '/get_playoffs',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    Map<String, dynamic> playoffs = jsonData;
    return playoffs;
  }
}
