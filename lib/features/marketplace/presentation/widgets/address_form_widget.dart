/// Address form widget for marketplace checkout.
///
/// Collects shipping address information from the buyer.
/// Returns a [ShippingAddress] via callback when the form is valid.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/shipping_address.dart';

/// A form widget for entering a shipping address.
///
/// Includes fields for name, phone, street, city, state, postal code,
/// and country code. Validates that required fields are filled.
class AddressFormWidget extends StatefulWidget {
  /// Creates an address form widget.
  const AddressFormWidget({
    required this.onAddressChanged,
    this.initialAddress,
    super.key,
  });

  /// Called when the address changes and all required fields are filled.
  final ValueChanged<ShippingAddress?> onAddressChanged;

  /// Optional initial address to pre-fill the form.
  final ShippingAddress? initialAddress;

  @override
  State<AddressFormWidget> createState() => _AddressFormWidgetState();
}

class _AddressFormWidgetState extends State<AddressFormWidget> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryCodeController;

  @override
  void initState() {
    super.initState();
    final addr = widget.initialAddress;
    _nameController = TextEditingController(text: addr?.personName ?? '');
    _phoneController = TextEditingController(text: addr?.phoneNumber ?? '');
    _streetController = TextEditingController(
      text: addr?.streetLines.isNotEmpty == true ? addr!.streetLines.first : '',
    );
    _cityController = TextEditingController(text: addr?.city ?? '');
    _stateController =
        TextEditingController(text: addr?.stateOrProvinceCode ?? '');
    _postalCodeController =
        TextEditingController(text: addr?.postalCode ?? '');
    _countryCodeController =
        TextEditingController(text: addr?.countryCode ?? 'US');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryCodeController.dispose();
    super.dispose();
  }

  void _onFieldChanged(String _) {
    final street = _streetController.text.trim();
    final city = _cityController.text.trim();
    final postalCode = _postalCodeController.text.trim();
    final countryCode = _countryCodeController.text.trim();

    if (street.isEmpty || city.isEmpty || postalCode.isEmpty || countryCode.isEmpty) {
      widget.onAddressChanged(null);
      return;
    }

    final address = ShippingAddress(
      streetLines: [street],
      city: city,
      postalCode: postalCode,
      countryCode: countryCode.toUpperCase(),
      stateOrProvinceCode:
          _stateController.text.trim().isNotEmpty
              ? _stateController.text.trim()
              : null,
      personName:
          _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
      phoneNumber:
          _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
    );

    widget.onAddressChanged(address);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Shipping Address'),
        const SizedBox(height: 10),

        // Full name
        LynewedTextField(
          controller: _nameController,
          hint: 'Full Name',
          onChanged: _onFieldChanged,
        ),
        const SizedBox(height: 12),

        // Phone
        LynewedTextField(
          controller: _phoneController,
          hint: 'Phone Number',
          keyboardType: TextInputType.phone,
          onChanged: _onFieldChanged,
        ),
        const SizedBox(height: 12),

        // Street address
        LynewedTextField(
          controller: _streetController,
          hint: 'Street Address',
          onChanged: _onFieldChanged,
        ),
        const SizedBox(height: 12),

        // City and State row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: LynewedTextField(
                controller: _cityController,
                hint: 'City',
                onChanged: _onFieldChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LynewedTextField(
                controller: _stateController,
                hint: 'State',
                onChanged: _onFieldChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Postal code and Country code row
        Row(
          children: [
            Expanded(
              child: LynewedTextField(
                controller: _postalCodeController,
                hint: 'Postal Code',
                keyboardType: TextInputType.number,
                onChanged: _onFieldChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LynewedTextField(
                controller: _countryCodeController,
                hint: 'Country Code',
                onChanged: _onFieldChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
