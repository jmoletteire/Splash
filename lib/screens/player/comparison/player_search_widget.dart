import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/player_avatar.dart';
import 'package:splash/utilities/constants.dart';

import '../../search_screen.dart';

class PlayerSearchWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) onPlayerSelected;

  PlayerSearchWidget({required this.onPlayerSelected});

  final TextEditingController _textEditingController = TextEditingController();

  void _showErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: kBebasNormal.copyWith(
          color: Colors.white,
          fontSize: 16.0.r,
        ),
      ),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
      showCloseIcon: true,
      closeIconColor: Colors.white,
      dismissDirection: DismissDirection.vertical,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            autofocus: true,
            autocorrect: false,
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
            style: kBebasNormal.copyWith(fontSize: 14.0.r),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                PlayerAvatar(
                                  radius: 20.0.r,
                                  backgroundColor: Colors.white12,
                                  playerImageUrl:
                                      'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['PERSON_ID']}.png',
                                ),
                                SizedBox(width: 15.0.r),
                                Text(
                                  player['DISPLAY_FIRST_LAST'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: kBebasNormal.copyWith(fontSize: 16.0.r),
                                ),
                              ],
                            ),
                            Text(
                              '${player['FROM_YEAR']} - ${player['TO_YEAR']}',
                              style: kBebasNormal.copyWith(
                                  color: Colors.white70, fontSize: 14.0.r),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (player['TO_YEAR'] < 1997) {
                            _showErrorSnackBar(context, 'Cannot compare players pre-1997');
                          } else {
                            onPlayerSelected(player);
                            Navigator.pop(context);
                          }
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
