// ignore_for_file: use_build_context_synchronously

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:heathbridge_lao/package.dart';
import 'package:heathbridge_lao/src/screens/home/widget/typedropdown.dart';

bool _isInitialized = false;

DropdownItem? dropdownValue;
List<DropdownItem> _dropdownItems = [];

class AddFacilityDialog extends StatefulWidget {
  const AddFacilityDialog({
    super.key,
    this.facilityInfo,
    this.isEditMode = false,
    this.userUID = '',
  });

  final Facilities? facilityInfo;
  final bool isEditMode;
  final String userUID;

  @override
  State<AddFacilityDialog> createState() => _AddFacilityDialogState();
}

class _AddFacilityDialogState extends State<AddFacilityDialog> {
  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (_isInitialized) return;
    _isInitialized = true;

    if (mounted) {
      setState(() {
        Set<DropdownItem> typeSet = _dropdownItems.toSet();
        for (var type in context.read<FacTypeProvider>().listInfo) {
          final newItem = DropdownItem(
            id: type.facTypeId!,
            name: "${type.nameLa} ${type.sub_type}",
          );
          typeSet.add(newItem);
        }
        _dropdownItems = typeSet.toList();
        dropdownValue = _dropdownItems.isNotEmpty ? _dropdownItems[0] : null;
      });
    }
    _isInitialized = false;
  }

  final _formKey = GlobalKey<FormBuilderState>();
  bool _isCanAdd = false;
  Future<void> _addFacility() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    formState.save();
    final formData = formState.value;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final HasuraConnect hasuraConnect = HasuraHelper.hasuraHelper;

      const String mutation = '''
      mutation AddFacility(
        \$name: String!
        \$fac_type_id: uuid!
        \$village: String!
        \$district: String!
        \$province: String!
        \$latitude: String!
        \$longitude: String!
        \$contact_info: String!
        \$image_url: String
        \$status: Int!
        \$user_id: uuid!
      ) {
        insert_facilities(
          objects: {
            name: \$name
            fac_type_id: \$fac_type_id
            village: \$village
            district: \$district
            province: \$province
            Latitude: \$latitude
            Longitude: \$longitude
            contact_info: \$contact_info
            image_url: \$image_url
            status: \$status
            user_id: \$user_id
          }
        ) {
          affected_rows
        }
      }
      ''';

      final variables = {
        'name': formData['name'],
        'fac_type_id': (formData['type'] as DropdownItem).id,
        'village': formData['village'] ?? '',
        'district': formData['district'] ?? '',
        'province': formData['province'] ?? '',
        'latitude': formData['latitude'] ?? '0',
        'longitude': formData['longitude'] ?? '0',
        'contact_info': formData['tel'],
        'image_url': null, // Ensure image_url is null
        'status': 2, // Assuming 1 is the default status for a new facility
        'user_id': widget.userUID,
      };

      final result =
          await hasuraConnect.mutation(mutation, variables: variables);

      Navigator.of(context).pop(); // Close loading dialog

      if (result['data']['insert_facilities']['affected_rows'] > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Facility added successfully')),
        );

        Navigator.of(context).pop(true); // Close the add facility dialog
      } else {
        throw Exception('Failed to add facility');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding facility: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateFacility() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    formState.save();
    final formData = formState.value;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final HasuraConnect hasuraConnect = HasuraHelper.hasuraHelper;

      const String mutation = '''
      mutation UpdateFacility(
        \$id: uuid!,
        \$name: String!,
        \$fac_type_id: uuid!,
        \$village: String!,
        \$district: String!,
        \$province: String!,
        \$latitude: String!,
        \$longitude: String!,
        \$contact_info: String!,
        \$image_url: String,
        \$status: Int!,
        \$user_id: uuid!
      ) {
        update_facilities(
          where: {fac_id: {_eq: \$id}},
          _set: {
            name: \$name,
            fac_type_id: \$fac_type_id,
            village: \$village,
            district: \$district,
            province: \$province,
            Latitude: \$latitude,
            Longitude: \$longitude,
            contact_info: \$contact_info,
            image_url: \$image_url,
            status: \$status,
            user_id: \$user_id
          }
        ) {
          affected_rows
        }
      }
      ''';

      final variables = {
        'id': widget.facilityInfo!.facId.toString(),
        'name': formData['name'],
        'fac_type_id': (formData['type'] as DropdownItem).id,
        'village': formData['village'] ?? '',
        'district': formData['district'] ?? '',
        'province': formData['province'] ?? '',
        'latitude': formData['latitude'] ?? '0',
        'longitude': formData['longitude'] ?? '0',
        'contact_info': formData['tel'],
        'image_url': null, // Ensure image_url is null
        'status': 2, // Assuming 1 is the default status for a new facility
        'user_id': widget.userUID,
      };
      // log((formData['type'] as DropdownItem).id.toString());
      // log(widget.facilityInfo!.facId.toString());
      // log(widget.userUID.toString());
      final result =
          await hasuraConnect.mutation(mutation, variables: variables);

      Navigator.of(context).pop(); // Close loading dialog

      if (result['data']['update_facilities']['affected_rows'] > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Facility updated successfully')),
        );
        Navigator.of(context).pop(true); // Close the add facility dialog
      } else {
        throw Exception('Failed to update facility');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating facility: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: FormBuilder(
            initialValue: widget.isEditMode && widget.facilityInfo != null
                ? {
                    'name': widget.facilityInfo!.name,
                    'village': widget.facilityInfo!.village,
                    'district': widget.facilityInfo!.district,
                    'province': widget.facilityInfo!.province,
                    'latitude': widget.facilityInfo!.latitude,
                    'longitude': widget.facilityInfo!.longitude,
                    'tel': widget.facilityInfo!.contactInfo,
                    'type': _dropdownItems.firstWhere(
                      (item) =>
                          item.id ==
                          widget.facilityInfo!.facilityType?.facTypeId,
                    ),
                  }
                : {
                    'name': 'ໂຮງໝໍສາກົນ ປະຕິພານ',
                    'village': 'ສວນມອນ',
                    'district': 'ສີສັດຕະນາກ',
                    'province': 'ນະຄອນຫຼວງວຽງຈັນ',
                    'latitude': '17.929304208440477',
                    'longitude': '102.61709268542914',
                    'tel': '+8562078357352',
                  },
            key: _formKey,
            child: Column(
              children: [
                FormBuilderTextField(
                  autofocus: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  cursorColor: ConstantColor.colorMain,
                  name: 'name',
                  style: const TextStyle(color: ConstantColor.colorMain),
                  decoration: const InputDecoration(
                      focusColor: ConstantColor.colorMain,
                      hoverColor: ConstantColor.colorMain,
                      hintText: "ໂຮງໝໍສາກົນ ປະຕິພານ..",
                      labelText: 'ຊື່ສະຖານທີ່',
                      labelStyle: TextStyle(color: ConstantColor.colorMain),
                      hintStyle: TextStyle(color: Colors.grey),
                      isDense: true,
                      border: OutlineInputBorder()),
                  onChanged: (val) {
                    setState(() {
                      if (_formKey.currentState!.validate()) {
                        _isCanAdd = true;
                      } else {
                        _isCanAdd = false;
                      }
                    });
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(10),
                  ]),
                  textInputAction: TextInputAction.none,
                ),
                const SizedBox(height: 10),
                FormBuilderDropdown<DropdownItem>(
                  name: 'type', // Change name to 'type' for consistency
                  // initialValue: dropdownValue ??
                  //     _dropdownItems.first, // Set initial value
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ປະເພດສະຖານທີ່ ', // Change label to 'Type'
                  ),
                  items: _dropdownItems
                      .map<DropdownMenuItem<DropdownItem>>(
                        (DropdownItem value) => DropdownMenuItem<DropdownItem>(
                          value: value,
                          child: Text(value.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      dropdownValue = val;
                      print(dropdownValue!.id);
                    });
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'tel',
                  style: const TextStyle(color: ConstantColor.colorMain),
                  decoration: InputDecorations.standardInputDecoration(
                    labelText: 'ເບີໂທລະສັບ',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  cursorColor: ConstantColor.colorMain,
                  onChanged: (val) {
                    setState(() {
                      if (_formKey.currentState!.validate()) {
                        _isCanAdd = true;
                      } else {
                        _isCanAdd = false;
                      }
                    });
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(12),
                  ]),
                  textInputAction: TextInputAction.none,
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'village',
                  decoration: InputDecorations.standardInputDecoration(
                    labelText: 'ບ້ານ',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  cursorColor: ConstantColor.colorMain,
                  onChanged: (val) {
                    setState(() {
                      if (_formKey.currentState!.validate()) {
                        _isCanAdd = true;
                      } else {
                        _isCanAdd = false;
                      }
                    });
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(5),
                  ]),
                  textInputAction: TextInputAction.none,
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'district',
                  decoration: InputDecorations.standardInputDecoration(
                    labelText: 'ເມືອງ',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  cursorColor: ConstantColor.colorMain,
                  onChanged: (val) {
                    setState(() {
                      if (_formKey.currentState!.validate()) {
                        _isCanAdd = true;
                      } else {
                        _isCanAdd = false;
                      }
                    });
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(5),
                  ]),
                  textInputAction: TextInputAction.none,
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'province',
                  decoration: InputDecorations.standardInputDecoration(
                    labelText: "ແຂວງ",
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  cursorColor: ConstantColor.colorMain,
                  onChanged: (val) {
                    setState(() {
                      if (_formKey.currentState!.validate()) {
                        _isCanAdd = true;
                      } else {
                        _isCanAdd = false;
                      }
                    });
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(5),
                  ]),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'latitude',
                  decoration: InputDecorations.standardInputDecoration(
                    labelText: 'ເສັ້ນເເວງ',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  cursorColor: ConstantColor.colorMain,
                  onChanged: (val) {
                    setState(() {
                      if (_formKey.currentState!.validate()) {
                        _isCanAdd = true;
                      } else {
                        _isCanAdd = false;
                      }
                    });
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(8),
                  ]),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'longitude',
                  decoration: InputDecorations.standardInputDecoration(
                    labelText: 'ເສັ້ນຂະໜານ',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  cursorColor: ConstantColor.colorMain,
                  onChanged: (val) {
                    setState(() {
                      if (_formKey.currentState!.validate()) {
                        _isCanAdd = true;
                      } else {
                        _isCanAdd = false;
                      }
                    });
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(8),
                  ]),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'.toUpperCase()),
                    ),
                    const SizedBox(width: 10),
                    !_isCanAdd && !widget.isEditMode
                        ? const SizedBox()
                        : ElevatedButton(
                            onPressed: () {
                              _formKey.currentState!.save();

                              if (widget.isEditMode) {
                                _updateFacility();
                              } else {
                                _addFacility();
                              }
                            },
                            child: Text(
                              widget.facilityInfo == null
                                  ? 'Add'.toUpperCase()
                                  : 'Update'.toUpperCase(),
                            ),
                          ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputDecorations {
  static InputDecoration standardInputDecoration({
    String? hintText,
    String? labelText,
    bool isDense = true,
    Color labelColor = ConstantColor.colorMain,
    Color hintColor = Colors.grey,
    Color focusColor = ConstantColor.colorMain,
    Color hoverColor = ConstantColor.colorMain,
    Widget? suffix,
  }) {
    return InputDecoration(
      isDense: isDense,
      hintText: hintText,
      labelText: labelText,
      labelStyle: TextStyle(color: labelColor),
      hintStyle: TextStyle(color: hintColor),
      focusColor: focusColor,
      hoverColor: hoverColor,
      border: const OutlineInputBorder(),
      suffix: suffix,
    );
  }
}
