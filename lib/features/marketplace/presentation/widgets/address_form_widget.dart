/// Address form widget for marketplace checkout.
///
/// Collects shipping address information from the buyer using:
/// - Google Places autocomplete for address lookup
/// - Country dropdown (pre-filled from autocomplete)
/// - Phone number field with country-aware formatting
/// Returns a [ShippingAddress] via callback when the form is valid.
///
/// Required fields: Full Name, Phone Number, Street, City, Postal Code, Country.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/backend/schema/structs/index.dart';
import '/compo_finaux/address_search/address_search_widget.dart';
import '/core/design/design.dart';
import '/core/utils/phone_number_formatter.dart';
import '../../data/sizes_data.dart';
import '../../domain/entities/shipping_address.dart';

/// A form widget for entering a shipping address.
///
/// Includes:
/// - Google Places autocomplete search bar at the top
/// - Full Name field (required)
/// - Phone Number field (required, country-aware formatting)
/// - Street Address field (pre-filled from autocomplete)
/// - City / State row (pre-filled from autocomplete)
/// - Postal Code / Country dropdown row (pre-filled from autocomplete)
///
/// All fields remain editable after autocomplete selection.
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

  String? _selectedCountryCode;
  PhoneNumberFormatter? _phoneFormatter;

  @override
  void initState() {
    super.initState();
    final addr = widget.initialAddress;
    _nameController = TextEditingController(text: addr?.personName ?? '');
    _streetController = TextEditingController(
      text: addr?.streetLines.isNotEmpty == true ? addr!.streetLines.first : '',
    );
    _cityController = TextEditingController(text: addr?.city ?? '');
    _stateController =
        TextEditingController(text: addr?.stateOrProvinceCode ?? '');
    _postalCodeController =
        TextEditingController(text: addr?.postalCode ?? '');
    _selectedCountryCode = addr?.countryCode;

    // Initialize phone formatter based on country
    if (_selectedCountryCode != null) {
      _phoneFormatter = PhoneNumberFormatter(
        PhoneNumberFormatter.configFor(_selectedCountryCode!),
      );
    }

    // Convert E.164 phone to display format if initial address provided
    if (addr?.phoneNumber != null && addr!.phoneNumber!.isNotEmpty) {
      if (_selectedCountryCode != null) {
        _phoneController = TextEditingController(
          text: PhoneNumberFormatter.fromE164(
            addr.phoneNumber!,
            _selectedCountryCode!,
          ),
        );
      } else {
        _phoneController =
            TextEditingController(text: addr.phoneNumber ?? '');
      }
    } else {
      _phoneController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  /// Called when a Google Places address is selected from autocomplete.
  void _onAddressAutocompleted(PlaceDetailsDataStruct details) {
    setState(() {
      // Build street from streetNumber + route.
      final parts = <String>[];
      if (details.hasStreetNumber() && details.streetNumber.isNotEmpty) {
        parts.add(details.streetNumber);
      }
      if (details.hasRoute() && details.route.isNotEmpty) {
        parts.add(details.route);
      }
      if (parts.isNotEmpty) {
        _streetController.text = parts.join(' ');
      } else if (details.hasFormattedAddress()) {
        _streetController.text = details.formattedAddress;
      }

      if (details.hasCity()) {
        _cityController.text = details.city;
      }
      if (details.hasStateCode()) {
        _stateController.text = details.stateCode;
      }
      if (details.hasPostalCode()) {
        _postalCodeController.text = details.postalCode;
      }
      if (details.hasCountryCode()) {
        // Try to match to our marketplace countries list.
        final code = details.countryCode.toUpperCase();
        final match = marketplaceCountries.where((c) => c.code == code);
        if (match.isNotEmpty) {
          _selectedCountryCode = match.first.code;
          _updatePhoneFormatter(match.first.code);
        }
      }
    });

    _notifyAddressChanged();
  }

  void _onFieldChanged(String _) {
    _notifyAddressChanged();
  }

  /// Updates the phone formatter when the country changes.
  void _updatePhoneFormatter(String countryCode) {
    _phoneFormatter = PhoneNumberFormatter(
      PhoneNumberFormatter.configFor(countryCode),
    );
    _reformatPhoneForCountry();
  }

  /// Re-formats existing phone text with the current country formatter.
  void _reformatPhoneForCountry() {
    final raw = PhoneNumberFormatter.rawDigits(_phoneController.text);
    if (raw.isEmpty) return;

    final formatted = _phoneFormatter?.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: raw,
        selection: TextSelection.collapsed(offset: raw.length),
      ),
    );
    if (formatted != null) {
      _phoneController.value = formatted;
    }
  }

  void _notifyAddressChanged() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final street = _streetController.text.trim();
    final city = _cityController.text.trim();
    final postalCode = _postalCodeController.text.trim();
    final countryCode = _selectedCountryCode;

    // All required fields must be non-empty
    if (name.isEmpty ||
        phone.isEmpty ||
        street.isEmpty ||
        city.isEmpty ||
        postalCode.isEmpty ||
        countryCode == null ||
        countryCode.isEmpty) {
      widget.onAddressChanged(null);
      return;
    }

    // Convert display phone to E.164 for storage/API
    final e164Phone = PhoneNumberFormatter.toE164(phone, countryCode);

    final address = ShippingAddress(
      streetLines: [street],
      city: city,
      postalCode: postalCode,
      countryCode: countryCode,
      stateOrProvinceCode: _stateController.text.trim().isNotEmpty
          ? _stateController.text.trim()
          : null,
      personName: name,
      phoneNumber: e164Phone,
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

        // Address autocomplete search
        AddressSearchWidget(
          hintText: 'Search your address',
          borderRadius: 4.0,
          locale: 'en',
          onAddressSelected: _onAddressAutocompleted,
        ),
        SizedBox(height: LynewedSpacing.lg),

        // Full name (required)
        LynewedTextField(
          controller: _nameController,
          hint: 'Full Name *',
          onChanged: _onFieldChanged,
        ),
        const SizedBox(height: 12),

        // Phone (required, country-aware formatting)
        LynewedTextField(
          controller: _phoneController,
          hint: _phoneFormatter != null
              ? 'Phone * (${_phoneFormatter!.config.exampleHint})'
              : 'Phone Number *',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            if (_phoneFormatter != null)
              _phoneFormatter!
            else
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-() .]')),
          ],
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

        // Postal code and Country dropdown row
        Row(
          children: [
            Expanded(
              child: LynewedTextField(
                controller: _postalCodeController,
                hint: 'Postal Code',
                keyboardType: TextInputType.text,
                onChanged: _onFieldChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCountryDropdown(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCountryCode,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Country',
        hintStyle: LynewedTextStyles.inputHint,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: LynewedColors.textPrimary,
            width: 1,
          ),
        ),
      ),
      style: LynewedTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w300,
      ),
      items: marketplaceCountries.map((c) {
        return DropdownMenuItem(
          value: c.code,
          child: Text(c.name, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (code) {
        setState(() {
          _selectedCountryCode = code;
          if (code != null) {
            _updatePhoneFormatter(code);
          }
        });
        _notifyAddressChanged();
      },
    );
  }
}
