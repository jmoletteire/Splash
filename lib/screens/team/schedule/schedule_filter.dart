/*
import 'package:flutter/material.dart';

import '../../../components/spinning_ball_loading.dart';
import '../../../utilities/constants.dart';

class ScheduleFilter extends StatefulWidget {
  final Map<String, dynamic> team;
  const ScheduleFilter({super.key, required this.team});

  @override
  State<ScheduleFilter> createState() => _ScheduleFilterState();
}

class _ScheduleFilterState extends State<ScheduleFilter> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _loading = false;
  int? _editIndex;

  final TextEditingController _valueController = TextEditingController();
  ValueNotifier<String?> _selectedFieldNotifier = ValueNotifier<String?>(null);
  String _operation = 'equals';
  String _location = '';

  @override
  Widget build(BuildContext context) {
    Color teamColor = kDarkPrimaryColors.contains(widget.team['ABBREVIATION'])
        ? (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: teamColor),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.fromLTRB(11.0, 11.0, 0.0, 11.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFieldNotifier = ValueNotifier<String?>(null);
          });
          _openBottomSheet();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: Row(
            children: [
              Text(
                selectedSeason,
                style: kBebasNormal.copyWith(fontSize: 18.0),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        borderRadius: BorderRadius.circular(10.0),
        menuMaxHeight: 300.0,
        dropdownColor: Colors.grey.shade900,
        isExpanded: false,
        underline: Container(),
        value: selectedValue,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: kBebasNormal.copyWith(fontSize: 18.0),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _openBottomSheet() {
    showModalBottomSheet(
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
                        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
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
                                    style: kBebasBold.copyWith(fontSize: 22.0),
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
                                          style:
                                              kBebasNormal.copyWith(color: Colors.deepOrange),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildDropdownButton(
                                    selectedValue: selectedSeason,
                                    items: kSeasons,
                                    onChanged: (value) {
                                      setModalState(() {
                                        selectedSeason = value!;
                                        oppId = int.parse(teamAbbr[selectedOpp]!);
                                        games = TeamGames(
                                          scrollController: widget.controller,
                                          team: widget.team,
                                          schedule: schedule,
                                          selectedSeason: selectedSeason,
                                          selectedMonth: selectedMonth,
                                          opponent: oppId,
                                        );
                                      });
                                    },
                                  ),
                                  _buildDropdownButton(
                                    selectedValue: selectedSeasonType,
                                    items: seasonTypes.keys,
                                    onChanged: (value) {
                                      setModalState(() {
                                        selectedSeasonType = value!;
                                        oppId = int.parse(teamAbbr[selectedOpp]!);
                                        games = TeamGames(
                                          scrollController: widget.controller,
                                          team: widget.team,
                                          schedule: schedule,
                                          selectedSeason: selectedSeason,
                                          selectedMonth: selectedMonth,
                                          opponent: oppId,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30.0),
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
                                      menuMaxHeight: 300.0,
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
                                            style: kBebasNormal.copyWith(fontSize: 16.5),
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
                                      style: kBebasNormal.copyWith(fontSize: 16.5),
                                      cursorColor: Colors.white70,
                                      decoration: InputDecoration(
                                          hintText: 'Value',
                                          hintStyle: kBebasNormal.copyWith(fontSize: 16.5)),
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
                              const SizedBox(height: 30.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 40.0,
                                    width: 40.0,
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
                                                color: Colors.black, fontSize: 14.0)
                                            : kBebasBold.copyWith(
                                                color: Colors.black, fontSize: 28.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25.0),
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
                                          style: kBebasNormal.copyWith(fontSize: 18.0),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.white70,
                                                size: 20.0,
                                              ),
                                              onPressed: () {
                                                _editFilter(index, setModalState);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline_outlined,
                                                color: Colors.red,
                                                size: 20.0,
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
                            child: SpinningIcon(color: teamColor),
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
*/
