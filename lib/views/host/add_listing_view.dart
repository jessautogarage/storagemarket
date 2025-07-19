// views/host/add_listing_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/listing_controller.dart';
import '../../config/theme.dart';
import '../widgets/primary_button.dart';

class AddListingView extends StatefulWidget {
  @override
  _AddListingViewState createState() => _AddListingViewState();
}

class _AddListingViewState extends State<AddListingView> {
  final ListingController listingController = Get.find();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();

  // Form State
  String _selectedSize = 'medium';
  List<File> _images = [];
  final _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  // Features
  Map<String, bool> _features = {
    '24/7 Access': false,
    'Climate Control': false,
    'Security Camera': false,
    'Ground Floor': false,
    'Electricity': false,
    'Vehicle Access': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Storage Space'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Section
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add up to 5 photos of your space',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._images.map((image) => _buildImageCard(image)),
                          if (_images.length < 5) _buildAddImageCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Basic Information
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g., Secure Garage in Makati',
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe your storage space...',
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    // Size Selection
                    Text(
                      'Size',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSizeOption('Small', 'small', '1-5 sqm'),
                        SizedBox(width: 12),
                        _buildSizeOption('Medium', 'medium', '6-15 sqm'),
                        SizedBox(width: 12),
                        _buildSizeOption('Large', 'large', '16+ sqm'),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price per Month',
                        hintText: '0.00',
                        prefixText: '₱ ',
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Location
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    SizedBox(height: 20),

                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        hintText: 'Enter complete address',
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        suffixIcon: Icon(Icons.location_on, color: AppColors.primary),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an address';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 12),

                    // Map Preview Placeholder
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 40, color: AppColors.secondaryText),
                            SizedBox(height: 8),
                            Text(
                              'Map preview will appear here',
                              style: TextStyle(color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Features
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _features.keys.map((feature) {
                        return FilterChip(
                          label: Text(feature),
                          selected: _features[feature]!,
                          onSelected: (selected) {
                            setState(() {
                              _features[feature] = selected;
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _features[feature]!
                                ? AppColors.primary
                                : AppColors.secondaryText,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Submit Button
              Container(
                padding: EdgeInsets.all(20),
                child: PrimaryButton(
                  text: 'List Storage Space',
                  onPressed: _isSubmitting ? null : _submitListing,
                  isLoading: _isSubmitting,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(File image) {
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _images.remove(image);
                });
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageCard() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: AppColors.primary,
            ),
            SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeOption(String label, String value, String description) {
    bool isSelected = _selectedSize == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSize = value;
          });
        },
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.primaryText,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitListing() async {
    if (_formKey.currentState!.validate()) {
      if (_images.isEmpty) {
        Get.snackbar(
          'Error',
          'Please add at least one photo',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        await listingController.createListing(
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          size: _selectedSize,
          address: _addressController.text,
          images: _images,
          features: _features.entries
              .where((e) => e.value)
              .map((e) => e.key)
              .toList(),
        );

        Get.back();
        Get.snackbar(
          'Success',
          'Your storage space has been listed!',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to create listing. Please try again.',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}