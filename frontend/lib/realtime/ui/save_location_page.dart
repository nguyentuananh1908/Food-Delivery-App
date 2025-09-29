import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SaveLocationPage extends StatefulWidget {
  final LatLng initialLocation;
  final String? address;

  const SaveLocationPage({
    Key? key,
    required this.initialLocation,
    this.address,
  }) : super(key: key);

  @override
  State<SaveLocationPage> createState() => _SaveLocationPageState();
}

class _SaveLocationPageState extends State<SaveLocationPage> {
  late GoogleMapController _mapController;
  LatLng _selectedLocation = const LatLng(21.0285, 105.8542);
  String _selectedLabel = 'home';
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _addressController.text = widget.address ?? '3235 Royal Ln. Mesa, New Jersey 34567';
    _streetController.text = 'Hason Nagar';
    _postalCodeController.text = '34567';
    _apartmentController.text = '345';
  }

  @override
  void dispose() {
    _streetController.dispose();
    _postalCodeController.dispose();
    _apartmentController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Save Location',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _buildMapSection(),
          ),
          Expanded(
            flex: 3,
            child: _buildAddressForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onTap: (LatLng location) {
              setState(() {
                _selectedLocation = location;
              });
              _mapController.animateCamera(
                CameraUpdate.newLatLng(location),
              );
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: _selectedLocation,
                draggable: true,
                onDragEnd: (LatLng newPosition) {
                  setState(() {
                    _selectedLocation = newPosition;
                  });
                },
              ),
            },
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            top: _selectedLocation.latitude,
            left: _selectedLocation.longitude,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Move to edit location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('ADDRESS'),
          const SizedBox(height: 8),
          _buildAddressField(),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildFieldSection('STREET', _streetController),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFieldSection('POST CODE', _postalCodeController),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildFieldSection('APARTMENT', _apartmentController),
          const SizedBox(height: 20),
          
          _buildSectionTitle('LABEL AS'),
          const SizedBox(height: 12),
          _buildLabelButtons(),
          const SizedBox(height: 30),
          
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildAddressField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _addressController,
        decoration: const InputDecoration(
          hintText: '3235 Royal Ln. Mesa, New Jersey 34567',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: Icon(Icons.location_on, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildFieldSection(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelButtons() {
    final labels = [
      {'key': 'home', 'label': 'Home'},
      {'key': 'work', 'label': 'Work'},
      {'key': 'other', 'label': 'Other'},
    ];

    return Row(
      children: labels.map((labelData) {
        final isSelected = _selectedLabel == labelData['key'];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: labelData == labels.last ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLabel = labelData['key']!;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  labelData['label']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveLocation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'SAVE LOCATION',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _saveLocation() {
    // TODO: Implement save location functionality
    final locationData = {
      'coordinates': _selectedLocation,
      'address': _addressController.text,
      'street': _streetController.text,
      'postalCode': _postalCodeController.text,
      'apartment': _apartmentController.text,
      'label': _selectedLabel,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Return the saved location data
    Navigator.pop(context, locationData);
  }
}


