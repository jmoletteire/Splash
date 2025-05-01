import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:splash/components/spinning_ball_loading.dart';

import '../../../components/custom_icon_button.dart';
import '../../../utilities/constants.dart';
import 'dropdown_search.dart';

class FiltersBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onDone;

  const FiltersBottomSheet({required this.onDone, super.key});

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  late String selectedSeason;
  late String seasonType;
  late String selectedPosition;
  final List<Map<String, dynamic>> filters = [];
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _loading = false;
  int? _editIndex;
  List<String> positions = ['ALL', 'G', 'F', 'C', 'G/F', 'F/C'];
  List<String> seasonTypes = ['REGULAR SEASON', 'PLAYOFFS'];
  List<String> seasons = [
    '2024-25',
    '2023-24',
    '2022-23',
    '2021-22',
    '2020-21',
    '2019-20',
    '2018-19',
    '2017-18',
    '2016-17',
    '2015-16',
    '2014-15',
    '2013-14',
    '2012-13',
    '2011-12',
    '2010-11',
    '2009-10',
    '2008-09',
    '2007-08',
    '2006-07',
    '2005-06',
    '2004-05',
    '2003-04',
    '2002-03',
    '2001-02',
    '2000-01',
    '1999-00',
    '1998-99',
    '1997-98',
    '1996-97'
  ];

  String _operation = 'equals';
  final TextEditingController _valueController = TextEditingController();
  ValueNotifier<String?> _selectedFieldNotifier = ValueNotifier<String?>(null);
  String _location = '';

  @override
  void initState() {
    super.initState();
    selectedSeason = seasons.first;
    seasonType = seasonTypes.first;
    selectedPosition = positions.first;
  }

  @override
  void dispose() {
    _valueController.dispose();
    _selectedFieldNotifier.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _selectedFieldNotifier.value != null && _valueController.text.isNotEmpty;
  }

  void _resetForm() {
    setState(() {
      _selectedFieldNotifier.value = null;
      _operation = 'equals';
      _valueController.clear();
      _autoValidate = false;
      _editIndex = null;
      _location = '';
    });
  }

  void _editFilter(int index, StateSetter setModalState) {
    setModalState(() {
      _selectedFieldNotifier.value = filters[index]['field'];
      _operation = filters[index]['operation'];
      _valueController.text = filters[index]['value'];
      _location = filters[index]['location'];
      _editIndex = index;
    });
  }

  void _removeFilter(int index, StateSetter setModalState) {
    setModalState(() {
      filters.removeAt(index);
      _resetForm();
    });
    setModalState(() {});
  }

  bool _requiresConversion(String field) {
    for (var category in kPlayerStatLabelMap.values) {
      if (category.containsKey(field)) {
        return category[field]['convert'] == 'true';
      }
    }
    return false;
  }

  String? _validateValue(String? value, String? operation) {
    if (value == null || value.isEmpty) {
      return 'Value cannot be empty';
    }
    final numValue = num.tryParse(value);
    if (numValue == null) {
      return 'Value must be a number';
    }
    if (!['top', 'bottom'].contains(operation) &
        _requiresConversion(_selectedFieldNotifier.value!)) {
      if (numValue < 0 || numValue > 1) {
        return 'Value must be between 0 and 1';
      }
    }
    return null;
  }

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

  Future<void> _submitData() async {
    setState(() {
      _loading = true;
    });
    final url = Uri.parse('https://$kFlaskUrl/stats-query');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'selectedSeason': selectedSeason,
        'selectedSeasonType': seasonType,
        'selectedPosition': selectedPosition,
        'filters': filters,
      }),
    );

    setState(() {
      _loading = false;
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      widget.onDone({
        'data': data,
        'selectedSeason': selectedSeason,
        'selectedSeasonType': seasonType,
        'selectedPosition': selectedPosition,
      });
    } else {
      _showErrorSnackBar(context, 'Error fetching data from server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      icon: Icons.filter_alt,
      size: 30.0.r,
      onPressed: () {
        setState(() {
          _selectedFieldNotifier = ValueNotifier<String?>(null);
        });
        _openBottomSheet();
      },
    );
  }

  Widget _buildDropdownButton({
    required String selectedValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: Colors.deepOrange),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: DropdownButton<String>(
        padding: EdgeInsets.symmetric(horizontal: 15.0.r),
        borderRadius: BorderRadius.circular(10.0),
        menuMaxHeight: 300.0.r,
        dropdownColor: Colors.grey.shade900,
        isExpanded: false,
        underline: Container(),
        value: selectedValue,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: kBebasNormal.copyWith(fontSize: 16.0.r),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _openBottomSheet() {
    showModalBottomSheet(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        scrollControlDisabledMaxHeightRatio: 0.65,
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
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0.r, vertical: 10.0.r),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _autoValidate
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Filter',
                                    style: kBebasBold.copyWith(fontSize: 20.0.r),
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: filters.isEmpty
                                            ? null
                                            : () {
                                                setModalState(() {
                                                  filters.clear();
                                                  _resetForm();
                                                });
                                              },
                                        child: Text(
                                          'CLEAR',
                                          style: kBebasNormal.copyWith(
                                            fontSize: 18.0.r,
                                            color: filters.isEmpty
                                                ? Colors.white24
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          _resetForm();
                                          setModalState(() {
                                            _loading = true;
                                          });
                                          await _submitData();
                                          setModalState(() {
                                            _loading = false;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Done',
                                          style: kBebasNormal.copyWith(
                                            fontSize: 18.0.r,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0.r),
                              Row(
                                mainAxisAlignment:
                                    MediaQuery.of(context).orientation == Orientation.landscape
                                        ? MainAxisAlignment.center
                                        : MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildDropdownButton(
                                    selectedValue: selectedSeason,
                                    items: seasons,
                                    onChanged: (value) {
                                      setModalState(() {
                                        selectedSeason = value!;
                                      });
                                    },
                                  ),
                                  if (MediaQuery.of(context).orientation ==
                                      Orientation.landscape)
                                    SizedBox(width: 50.0.r),
                                  _buildDropdownButton(
                                    selectedValue: seasonType,
                                    items: seasonTypes,
                                    onChanged: (value) {
                                      setModalState(() {
                                        seasonType = value!;
                                      });
                                    },
                                  ),
                                  if (MediaQuery.of(context).orientation ==
                                      Orientation.landscape)
                                    SizedBox(width: 50.0.r),
                                  _buildDropdownButton(
                                    selectedValue: selectedPosition,
                                    items: positions,
                                    onChanged: (value) {
                                      setModalState(() {
                                        selectedPosition = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 30.0.r),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: MyDropdownSearch(
                                      onChanged: (value) {
                                        setModalState(() {
                                          _selectedFieldNotifier.value = value;
                                        });
                                      },
                                      onLocationChanged: (location) {
                                        setModalState(() {
                                          _location = location;
                                        });
                                      },
                                      selectedItemNotifier: _selectedFieldNotifier,
                                    ),
                                  ),
                                  const Spacer(),
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String>(
                                      value: _operation,
                                      borderRadius: BorderRadius.circular(10.0),
                                      menuMaxHeight: 300.0.r,
                                      dropdownColor: Colors.grey.shade900,
                                      items: [
                                        'equals',
                                        'greater than',
                                        'less than',
                                        'top',
                                        'bottom'
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: kBebasNormal.copyWith(fontSize: 14.5.r),
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
                                      controller: _valueController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(decimal: true),
                                      style: kBebasNormal.copyWith(fontSize: 14.5.r),
                                      cursorColor: Colors.white70,
                                      decoration: InputDecoration(
                                          hintText: 'Value',
                                          hintStyle: kBebasNormal.copyWith(fontSize: 14.5.r)),
                                      onChanged: (value) {
                                        setModalState(() {
                                          _valueController.text = value;
                                        });
                                      },
                                      onTapOutside: (event) {
                                        FocusScope.of(context).unfocus();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30.0.r),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 40.0.r,
                                    width: 40.0.r,
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        setModalState(() {
                                          _autoValidate = true;
                                        });
                                        final validationError =
                                            _validateValue(_valueController.text, _operation);
                                        if (validationError != null) {
                                          _showErrorSnackBar(context, validationError);
                                          return;
                                        }
                                        if (_isFormValid()) {
                                          if (_formKey.currentState!.validate()) {
                                            _formKey.currentState!.save();
                                            setModalState(() {
                                              if (_editIndex != null) {
                                                filters[_editIndex!] = {
                                                  'field': _selectedFieldNotifier.value!,
                                                  'operation': _operation,
                                                  'value': _valueController.text,
                                                  'location': _location,
                                                };
                                              } else {
                                                filters.add({
                                                  'field': _selectedFieldNotifier.value!,
                                                  'operation': _operation,
                                                  'value': _valueController.text,
                                                  'location': _location,
                                                });
                                              }
                                            });
                                            _resetForm();
                                          }
                                        }
                                      },
                                      backgroundColor:
                                          _isFormValid() ? Colors.deepOrange : Colors.grey,
                                      child: Text(
                                        _editIndex != null ? '✓' : '+',
                                        style: _editIndex != null
                                            ? kBebasBold.copyWith(
                                                color: Colors.black, fontSize: 12.0.r)
                                            : kBebasBold.copyWith(
                                                color: Colors.black, fontSize: 26.0.r),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 25.0.r),
                              Expanded(
                                child: ClipRect(
                                  child: ListView.builder(
                                    itemCount: filters.length,
                                    itemBuilder: (context, index) {
                                      final filter = filters[index];
                                      return ListTile(
                                        shape: const Border(
                                          bottom: BorderSide(
                                            color: Colors.white,
                                            width: 0.25,
                                          ),
                                        ),
                                        title: Text(
                                          '${filter['field']} ${filter['operation']} ${filter['value']}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: kBebasNormal.copyWith(fontSize: 16.0.r),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.white70,
                                                size: 20.0.r,
                                              ),
                                              onPressed: () {
                                                _editFilter(index, setModalState);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.remove_circle_outline_outlined,
                                                color: Colors.red,
                                                size: 20.0.r,
                                              ),
                                              onPressed: () {
                                                _removeFilter(index, setModalState);
                                                setModalState(() {
                                                  _formKey.currentState?.validate();
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_loading)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: SpinningIcon(color: Colors.deepOrange),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
