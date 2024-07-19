import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splash/utilities/constants.dart';

import '../../search_screen.dart';

class TeamSearchWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) onTeamSelected;

  TeamSearchWidget({required this.onTeamSelected});

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          TextField(
            autofocus: true,
            controller: _textEditingController,
            onChanged: (query) =>
                Provider.of<SearchProvider>(context, listen: false).onSearchChanged(query),
            decoration: InputDecoration(
              hintText: 'Search',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18.0),
                borderSide: const BorderSide(
                  color: Colors.deepOrange,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18.0),
                borderSide: const BorderSide(
                  color: Colors.white70,
                ),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  // Clear the text field
                  _textEditingController.clear();
                  Provider.of<SearchProvider>(context, listen: false).onSearchChanged('');
                },
              ),
            ),
            style: kBebasNormal.copyWith(fontSize: 18.0),
            cursorColor: Colors.white,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                return ListView(
                  children: [
                    ...searchProvider.teamSuggestions.map(
                      (team) => ListTile(
                        shape: const Border(
                          bottom: BorderSide(
                            color: Colors.grey, // Set the color of the border
                            width: 0.125, // Set the width of the border
                          ),
                        ),
                        title: Row(
                          children: [
                            Image.asset(
                              'images/NBA_Logos/${team['TEAM_ID']}.png',
                              width: 35,
                            ),
                            const SizedBox(
                              width: 15.0,
                            ),
                            Text(
                              '${team['CITY']} ${team['NICKNAME']}',
                              style: kBebasNormal.copyWith(fontSize: 18.0),
                            ),
                          ],
                        ),
                        onTap: () {
                          onTeamSelected(team);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
