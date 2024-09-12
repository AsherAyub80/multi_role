import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:multi_role/docscanner/filter_preview.dart';

class DocScanner extends StatefulWidget {
  const DocScanner({Key? key}) : super(key: key);

  @override
  _DocScannerState createState() => _DocScannerState();
}

class _DocScannerState extends State<DocScanner> {
  final List<String> _pictures = [];
  bool _isLoading = false;
  Future<String?>? _navigationFuture;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchPictures() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newPictures = await CunningDocumentScanner.getPictures();
      if (newPictures != null) {
        setState(() {
          _pictures.addAll(newPictures);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No pictures returned')),
        );
      }
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning documents: $exception')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openFilterPreview(String imagePath) async {
    setState(() {
      _navigationFuture = Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => FilterPreviewScreen(imagePath: imagePath),
        ),
      )
          .then((updatedImagePath) {
        if (updatedImagePath != null) {
          setState(() {
            final index = _pictures.indexOf(imagePath);
            if (index != -1) {
              _pictures[index] = updatedImagePath;
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Document Scanner'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fetchPictures,
            icon: Icon(Icons.add_a_photo),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      'assets/scan.gif',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Scanning...',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : FutureBuilder<void>(
              future: _navigationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Text('Loading...'),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error occurred: ${snapshot.error}'),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Expanded(
                          child: _pictures.isEmpty
                              ? Center(child: Text('No pictures found'))
                              : GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8.0,
                                    mainAxisSpacing: 8.0,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: _pictures.length,
                                  itemBuilder: (context, index) {
                                    final picture = _pictures[index];
                                    return GestureDetector(
                                      onTap: () => _openFilterPreview(picture),
                                      child: Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            File(picture),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
    );
  }
}
