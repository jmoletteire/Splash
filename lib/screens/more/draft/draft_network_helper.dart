import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class DraftNetworkHelper {
  Network network = Network();

  Future<List> getDraft(String draftYear) async {
    // Create the query parameters map
    Map<String, String> queryParams = {'draftYear': draftYear};

    // Create the URL with query parameters
    var url = Uri.https(
      kFlaskUrl,
      '/get_draft',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    List draft = jsonData['SELECTIONS'];
    return draft;
  }
}
