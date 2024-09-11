import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class TransactionsNetworkHelper {
  Network network = Network();

  Future<List> getTransactions() async {
    // Create the query parameters map
    Map<String, String> queryParams = {};

    // Create the URL with query parameters
    var url = Uri.http(
      kFlaskUrl,
      '/get_transactions',
      queryParams,
    );

    // Fetch the data from the network
    dynamic jsonData = await network.getData(url);
    List transactions = jsonData;
    return jsonData;
  }
}
