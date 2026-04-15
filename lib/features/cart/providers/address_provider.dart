import 'package:flutter/material.dart';
import '../../../core/models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final List<AddressModel> _addresses = [];
  String? _selectedAddressId;

  List<AddressModel> get addresses => [..._addresses];
  String? get selectedAddressId => _selectedAddressId;

  AddressModel? get selectedAddress {
    if (_selectedAddressId == null) return null;
    try {
      return _addresses.firstWhere((addr) => addr.id == _selectedAddressId);
    } catch (_) {
      return null;
    }
  }

  void selectAddress(String id) {
    _selectedAddressId = id;
    notifyListeners();
  }

  void addAddress(String title, String address) {
    final newAddress = AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? 'Այլ' : title,
      address: address,
    );
    _addresses.add(newAddress);
    _selectedAddressId = newAddress.id;
    notifyListeners();
  }

  void removeAddress(String id) {
    _addresses.removeWhere((addr) => addr.id == id);
    if (_selectedAddressId == id) {
      _selectedAddressId = _addresses.isNotEmpty ? _addresses.first.id : null;
    }
    notifyListeners();
  }
}
