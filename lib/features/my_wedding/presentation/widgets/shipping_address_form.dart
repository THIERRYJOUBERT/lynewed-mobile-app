/// Shipping Address Form widget for magazine checkout.
///
/// Form for entering shipping address with validation.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';

import '../../domain/entities/shipping_address.dart';

/// Form for entering shipping address.
class ShippingAddressForm extends StatefulWidget {
  /// Creates a shipping address form.
  const ShippingAddressForm({
    super.key,
    required this.address,
    required this.onAddressChanged,
  });

  /// Current shipping address.
  final ShippingAddress address;

  /// Callback when address changes.
  final void Function(ShippingAddress) onAddressChanged;

  @override
  State<ShippingAddressForm> createState() => _ShippingAddressFormState();
}

class _ShippingAddressFormState extends State<ShippingAddressForm> {
  late TextEditingController _nameController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _zipController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address.fullName);
    _addressLine1Controller =
        TextEditingController(text: widget.address.addressLine1);
    _addressLine2Controller =
        TextEditingController(text: widget.address.addressLine2 ?? '');
    _cityController = TextEditingController(text: widget.address.city);
    _zipController = TextEditingController(text: widget.address.zipCode);
  }

  @override
  void didUpdateWidget(ShippingAddressForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers if address changed externally
    if (widget.address.fullName != _nameController.text) {
      _nameController.text = widget.address.fullName;
    }
    if (widget.address.addressLine1 != _addressLine1Controller.text) {
      _addressLine1Controller.text = widget.address.addressLine1;
    }
    if ((widget.address.addressLine2 ?? '') != _addressLine2Controller.text) {
      _addressLine2Controller.text = widget.address.addressLine2 ?? '';
    }
    if (widget.address.city != _cityController.text) {
      _cityController.text = widget.address.city;
    }
    if (widget.address.zipCode != _zipController.text) {
      _zipController.text = widget.address.zipCode;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final updated = widget.address.copyWith(
      fullName: _nameController.text.trim(),
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim().isNotEmpty
          ? _addressLine2Controller.text.trim()
          : null,
      clearAddressLine2: _addressLine2Controller.text.trim().isEmpty,
      city: _cityController.text.trim(),
      zipCode: _zipController.text.trim(),
    );
    widget.onAddressChanged(updated);
  }

  void _onCountryChanged(String country) {
    final updated = widget.address.copyWith(country: country);
    widget.onAddressChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full name
        _buildSectionTitle('Full name *'),
        LynewedTextField(
          controller: _nameController,
          hint: 'John Doe',
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 20),

        // Address line 1
        _buildSectionTitle('Address line 1 *'),
        LynewedTextField(
          controller: _addressLine1Controller,
          hint: '123 Main Street',
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 20),

        // Address line 2 (optional)
        _buildSectionTitle('Address line 2'),
        LynewedTextField(
          controller: _addressLine2Controller,
          hint: 'Apartment, suite, etc. (optional)',
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 20),

        // City and ZIP
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('City *'),
                  LynewedTextField(
                    controller: _cityController,
                    hint: 'City',
                    onChanged: (_) => _onFieldChanged(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('ZIP *'),
                  LynewedTextField(
                    controller: _zipController,
                    hint: 'ZIP',
                    onChanged: (_) => _onFieldChanged(),
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Country dropdown
        _buildSectionTitle('Country *'),
        _buildCountryDropdown(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: LynewedTextStyles.sectionTitle),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: LynewedColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.address.country,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          borderRadius: BorderRadius.circular(8),
          items: ShippingCountries.all.map((country) {
            return DropdownMenuItem<String>(
              value: country.code,
              child: Text(
                country.name,
                style: LynewedTextStyles.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _onCountryChanged(value);
            }
          },
        ),
      ),
    );
  }
}
