import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:multi_role/docscanner/image_editing.dart';
import 'package:path_provider/path_provider.dart';

class FilterPreviewScreen extends StatefulWidget {
  final String imagePath;

  const FilterPreviewScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  _FilterPreviewScreenState createState() => _FilterPreviewScreenState();
}

class _FilterPreviewScreenState extends State<FilterPreviewScreen> {
  late img.Image _image;
  String _selectedFilter = 'original'; // Track selected filter
  final Map<String, Uint8List> _filterCache = {}; // Cache for filtered images

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final imageBytes = File(widget.imagePath).readAsBytesSync();
    setState(() {
      _image = img.decodeImage(imageBytes)!;
    });
    _preloadFilteredImages(); // Preload all filtered images
  }

  Future<void> _preloadFilteredImages() async {
    final filterTypes = [
      'original',
      'grayscale',
      'invert',
      'sepia',
      'brightness',
      'contrast',
      'saturation',
      'monochrome',
      'sketch',
    ];

    for (var filterType in filterTypes) {
      final filteredImage = await _getFilteredImage(filterType);
      _filterCache[filterType] = filteredImage;
    }
    setState(() {});
  }

  Future<void> _applyFilter(String filterType) async {
    setState(() {
      _selectedFilter = filterType; // Update selected filter
    });
    // Update image with the selected filter
    final editedFile = await applyFilter(File(widget.imagePath), filterType);
    final editedBytes = editedFile.readAsBytesSync();
    setState(() {
      _image = img.decodeImage(editedBytes)!;
    });
  }

  Future<Uint8List> _getFilteredImage(String filterType) async {
    final editedFile = await applyFilter(File(widget.imagePath), filterType);
    return Uint8List.fromList(editedFile.readAsBytesSync());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Preview'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveImage,
          ),
        ],
      ),
      // ignore: unnecessary_null_comparison
      body: _image == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child:
                      Image.memory(Uint8List.fromList(img.encodeJpg(_image))),
                ),
                SizedBox(height: 10),
                _buildFilterOptions(),
              ],
            ),
    );
  }

  Widget _buildFilterOptions() {
    final filterTypes = [
      'original',
      'grayscale',
      'invert',
      'sepia',
      'brightness',
      'contrast',
      'saturation',
      'monochrome',
      'sketch',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterTypes.map((filterType) {
          return _buildFilterContainer(filterType);
        }).toList(),
      ),
    );
  }

  Widget _buildFilterContainer(String filterType) {
    final isSelected = _selectedFilter == filterType;
    final imageBytes = _filterCache[filterType];

    return GestureDetector(
      onTap: () => _applyFilter(filterType),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(
                        color: Colors.blue, width: 3) // Selected border
                    : null,
                image: imageBytes != null
                    ? DecorationImage(
                        image: MemoryImage(imageBytes),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageBytes == null
                  ? Center(child: CircularProgressIndicator())
                  : null, // Show loader while image is being loaded
            ),
            SizedBox(height: 8),
            Text(filterType,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_edited.jpg';
    final file = File(path)..writeAsBytesSync(img.encodeJpg(_image)!);

    Navigator.of(context)
        .pop(file.path); // Return the saved file path to the previous screen
  }
}
