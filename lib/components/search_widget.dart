import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splash/utilities/constants.dart';

import '../screens/search_screen.dart';

class SearchWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) onPlayerSelected;

  SearchWidget({required this.onPlayerSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          TextField(
            autofocus: true,
            onChanged: (query) =>
                Provider.of<SearchProvider>(context, listen: false)
                    .onSearchChanged(query),
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
                    ...searchProvider.playerSuggestions.map(
                      (player) => ListTile(
                        shape: const Border(
                          bottom: BorderSide(
                            color: Colors.grey, // Set the color of the border
                            width: 0.125, // Set the width of the border
                          ),
                        ),
                        title: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.0,
                              backgroundColor: Colors.white12,
                              foregroundColor: Colors.white12,
                              foregroundImage: NetworkImage(
                                  'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['PERSON_ID']}.png'),
                            ),
                            const SizedBox(
                              width: 15.0,
                            ),
                            Text(
                              player['DISPLAY_FIRST_LAST'],
                              style: kBebasNormal.copyWith(fontSize: 18.0),
                            ),
                          ],
                        ),
                        onTap: () {
                          onPlayerSelected(player);
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
