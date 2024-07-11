import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class Team {
  Network network = Network();

  Future<Map<String, dynamic>> getTeam(String teamId,
      [List<String>? fields]) async {
    Map<String, String> queryParams = {'team_id': teamId};
    if (fields != null && fields.isNotEmpty) {
      queryParams['fields'] = fields.join(',');
    }

    var url = Uri.http(
      kFlaskUrl,
      '/get_team',
      queryParams,
    );

    dynamic jsonData = await network.getData(url);
    Map<String, dynamic> team = jsonData;
    return team;
  }

  Future<Map<String, dynamic>> getTeamStats(
      String teamId, String season) async {
    var url = Uri.http(
      kFlaskUrl,
      '/get_team_stats',
      {'team_id': teamId, 'season': season},
    );

    dynamic jsonData = await network.getData(url);
    Map<String, dynamic> teamStats = jsonData['STATS'];
    return teamStats;
  }
}
