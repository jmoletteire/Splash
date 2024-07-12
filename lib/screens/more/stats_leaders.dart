import 'package:flutter/material.dart';
import 'package:splash/components/dropdown_search.dart';

import '../../components/custom_icon_button.dart';
import '../../utilities/constants.dart';
import '../search_screen.dart';

class Leaders extends StatefulWidget {
  const Leaders({super.key});

  @override
  State<Leaders> createState() => _LeadersState();
}

class _LeadersState extends State<Leaders> {
  late String selectedSeason;
  late String seasonType;

  List<String> seasonTypes = ['Regular Season', 'Playoffs'];

  @override
  void initState() {
    super.initState();
    selectedSeason = kSeasons.first;
    seasonType = seasonTypes.first;
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
          CustomIconButton(
            icon: Icons.filter_alt,
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: const Color(0xFF111111),
                context: context,
                builder: (BuildContext context) {
                  final _formKey = GlobalKey<FormState>();
                  String _field = '';
                  String _operation = 'equals';
                  String _value = '';

                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Colors.deepOrange,
                        onPrimary: Colors.white,
                        secondary: Colors.white,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filter',
                                style: kBebasBold.copyWith(fontSize: 22.0),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Done',
                                  style: kBebasNormal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    border:
                                        Border.all(color: Colors.deepOrange),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: DropdownButton<String>(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                  menuMaxHeight: 300.0,
                                  dropdownColor: Colors.grey.shade900,
                                  isExpanded: false,
                                  underline: Container(),
                                  value: selectedSeason,
                                  items: kSeasons.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: kBebasNormal.copyWith(
                                            fontSize: 18.0),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedSeason = value!;
                                    });
                                  },
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    border:
                                        Border.all(color: Colors.deepOrange),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: DropdownButton<String>(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                  menuMaxHeight: 300.0,
                                  dropdownColor: Colors.grey.shade900,
                                  isExpanded: false,
                                  underline: Container(),
                                  value: seasonType,
                                  items: seasonTypes
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: kBebasNormal.copyWith(
                                            fontSize: 18.0),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      seasonType = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 4,
                                child: MyDropdownSearch(),
                              ),
                              const Spacer(),
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: _operation,
                                  borderRadius: BorderRadius.circular(10.0),
                                  menuMaxHeight: 300.0,
                                  dropdownColor: Colors.grey.shade900,
                                  items: [
                                    'equals',
                                    'contains',
                                    'greater than',
                                    'less than'
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: kBebasNormal.copyWith(
                                            fontSize: 16.5),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _operation = newValue!;
                                    });
                                  },
                                ),
                              ),
                              const Spacer(),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  style: kBebasNormal.copyWith(fontSize: 16.5),
                                  cursorColor: Colors.white70,
                                  decoration: InputDecoration(
                                      hintText: 'Value',
                                      hintStyle: kBebasNormal.copyWith(
                                          fontSize: 16.5)),
                                  onSaved: (value) => _value = value!,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
