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
          FiltersBottomSheet()
        ],
      ),
    );
  }
}
