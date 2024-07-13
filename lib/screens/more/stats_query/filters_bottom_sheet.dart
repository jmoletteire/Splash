import 'package:flutter/material.dart';

import '../../../components/custom_icon_button.dart';
import '../../../utilities/constants.dart';
import 'dropdown_search.dart';

class FiltersBottomSheet extends StatefulWidget {
  const FiltersBottomSheet({super.key});

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  late String selectedSeason;
  late String seasonType;
  final List<Map<String, dynamic>> filters = [];
  final _formKey = GlobalKey<FormState>();

  List<String> seasonTypes = ['Regular Season', 'Playoffs'];
  List<String> positions = ['G', 'F', 'C', 'G-F', 'F-C'];

  String _field = '';
  String _operation = 'equals';
  String _value = '';

  @override
  void initState() {
    super.initState();
    selectedSeason = kSeasons.first;
    seasonType = seasonTypes.first;
  }

  bool _isFormValid() {
    return _field.isNotEmpty && _value.isNotEmpty;
  }

  void _resetForm() {
    setState(() {
      _field = '';
      _operation = 'equals';
      _value = '';
    });
  }

  void _removeFilter(int index, StateSetter setModalState) {
    setModalState(() {
      filters.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
        icon: Icons.filter_alt,
        onPressed: () {
          showModalBottomSheet(
              backgroundColor: const Color(0xFF111111),
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return PopScope(
                      onPopInvoked: (popped) {
                        _resetForm();
                      },
                      child: Theme(
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Filter',
                                      style:
                                          kBebasBold.copyWith(fontSize: 22.0),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: filters.isEmpty
                                              ? null
                                              : () {
                                                  setModalState(() {
                                                    filters.clear();
                                                  });
                                                },
                                          child: Text(
                                            'CLEAR ALL',
                                            style: kBebasNormal.copyWith(
                                              color: filters.isEmpty
                                                  ? Colors.white24
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _resetForm();
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Done',
                                            style: kBebasNormal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade900,
                                          border: Border.all(
                                              color: Colors.deepOrange),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: DropdownButton<String>(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        menuMaxHeight: 300.0,
                                        dropdownColor: Colors.grey.shade900,
                                        isExpanded: false,
                                        underline: Container(),
                                        value: selectedSeason,
                                        items: kSeasons
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
                                          setModalState(() {
                                            selectedSeason = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade900,
                                          border: Border.all(
                                              color: Colors.deepOrange),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: DropdownButton<String>(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                          setModalState(() {
                                            seasonType = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: MyDropdownSearch(
                                        onChanged: (value) {
                                          setModalState(() {
                                            _field = value;
                                          });
                                        },
                                      ),
                                    ),
                                    const Spacer(),
                                    Expanded(
                                      flex: 3,
                                      child: DropdownButtonFormField<String>(
                                        value: _operation,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                          setModalState(() {
                                            _operation = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                    const Spacer(),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        style: kBebasNormal.copyWith(
                                            fontSize: 16.5),
                                        cursorColor: Colors.white70,
                                        decoration: InputDecoration(
                                            hintText: 'Value',
                                            hintStyle: kBebasNormal.copyWith(
                                                fontSize: 16.5)),
                                        onChanged: (value) {
                                          setModalState(() {
                                            _value = value;
                                          });
                                        },
                                        onSaved: (value) => _value = value!,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 40.0,
                                      width: 40.0,
                                      child: FloatingActionButton(
                                        onPressed: _isFormValid()
                                            ? () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  _formKey.currentState!.save();
                                                  setModalState(() {
                                                    filters.add({
                                                      'field': _field,
                                                      'operation': _operation,
                                                      'value': _value,
                                                    });
                                                  });
                                                  print(filters);
                                                  _resetForm();
                                                }
                                              }
                                            : null,
                                        child: Text(
                                          '+',
                                          style: kBebasBold.copyWith(
                                              color: Colors.black,
                                              fontSize: 28.0),
                                        ),
                                        backgroundColor: _isFormValid()
                                            ? Colors.deepOrange
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25.0),
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: filters.length,
                                    itemBuilder: (context, index) {
                                      final filter = filters[index];
                                      return ListTile(
                                        shape: const Border(
                                          bottom: BorderSide(
                                            color: Colors
                                                .white, // Set the color of the border
                                            width:
                                                0.25, // Set the width of the border
                                          ),
                                        ),
                                        title: Text(
                                          '${filter['field']} ${filter['operation']} ${filter['value']}',
                                          style: kBebasNormal,
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            _removeFilter(index, setModalState);
                                            setModalState(() {
                                              // Ensure revalidation
                                              _formKey.currentState?.validate();
                                            })
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              });
        });
  }
}
