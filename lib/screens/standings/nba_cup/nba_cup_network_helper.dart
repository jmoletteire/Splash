import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class NbaCupNetworkHelper {
  Network network = Network();

  Future<Map<String, dynamic>> getNbaCup(String season) async {
    // Create the query parameters map
    Map<String, String> queryParams = {'season': season};

    // Create the URL with query parameters
    var url = Uri.https(
      kFlaskUrl,
      '/get_nba_cup',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    Map<String, dynamic> cup = jsonData;
    return cup;
  }
}
