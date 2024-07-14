import 'package:flutter/material.dart';
import 'package:splash/screens/more/stats_query/filters_bottom_sheet.dart';

import '../../../components/custom_icon_button.dart';
import '../../search_screen.dart';

class Leaders extends StatefulWidget {
  const Leaders({super.key});

  @override
  State<Leaders> createState() => _LeadersState();
}

class _LeadersState extends State<Leaders> {
  Map<String, dynamic>? queryData;

  void _handleFiltersDone(Map<String, dynamic> data) {
    setState(() {
      queryData = data;
      // Use the data as needed, e.g., make another API call, update the UI, etc.
      print('Received data: $data');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        surfaceTintColor: Colors.grey.shade900,
        title: const Text(
          'Leaders',
          style: TextStyle(
              color: Colors.white, fontFamily: 'Bebas_Neue', fontSize: 28.0),
        ),
        actions: [
          CustomIconButton(
            icon: Icons.search,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                ),
              );
            },
          ),
          FiltersBottomSheet(onDone: _handleFiltersDone)
        ],
      ),
      body: Center(
        child: queryData == null
            ? Text(
                'No data',
                style: TextStyle(color: Colors.white),
              )
            : Text(
                'Data received: ${queryData!['data'][0]['DISPLAY_FI_LAST']}',
                style: TextStyle(color: Colors.white),
              ),
      ),
    );
  }
}
