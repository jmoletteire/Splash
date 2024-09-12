import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class DraftNetworkHelper {
  Network network = Network();

  Future<Map<String, dynamic>> getDraft(String draftYear) async {
    // Create the query parameters map
    Map<String, String> queryParams = {'draftYear': draftYear};

    // Create the URL with query parameters
    var url = Uri.http(
      kFlaskUrl,
      '/get_draft',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    Map<String, dynamic> draft = jsonData;
    return draft;
  }

  Future<List> getDraftByPick(String pickNumber) async {
    // Create the query parameters map
    Map<String, String> queryParams = {'overallPick': pickNumber};

    // Create the URL with query parameters
    var url = Uri.http(
      kFlaskUrl,
      '/get_draft/by_pick',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    List draft = jsonData;
    return draft;
  }
}
