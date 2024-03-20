import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_file/open_file.dart';

class UploadedFile extends StatefulWidget {
  const UploadedFile({Key? key}) : super(key: key);

  @override
  State<UploadedFile> createState() => _UploadedFileState();
}

class _UploadedFileState extends State<UploadedFile> {
  List<File> _imageFiles = []; // List to hold downloaded image files
  List<File> _documentFiles = []; // List to hold downloaded document files

  @override
  void initState() {
    super.initState();
    _loadSavedFiles();
  }

  Future<void> _loadSavedFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load saved image file paths
      _imageFiles = (prefs.getStringList('imageFiles') ?? [])
          .map((path) => File(path))
          .toList();
      // Load saved document file paths
      _documentFiles = (prefs.getStringList('documentFiles') ?? [])
          .map((path) => File(path))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Files'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildButtonWithIcon(
                onPressed: _selectAndDownloadImage,
                label: 'Select and Download Image',
                icon: Icons.download,
              ),
              // Display downloaded images
              if (_imageFiles.isNotEmpty)
                Column(
                  children: _imageFiles
                      .map((file) => Container(
                            margin: const EdgeInsets.all(20),
                            child: Image.file(
                              file,
                              width: 200,
                              height: 200,
                            ),
                          ))
                      .toList(),
                ),
              ElevatedButton(
                onPressed: _selectAndDownloadDocument,
                child: const Text('Select and Download Document'),
              ),
              // Display downloaded documents
              if (_documentFiles.isNotEmpty)
                Column(
                  children: _documentFiles
                      .map((file) => Container(
                            margin: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  'Selected Document: ${file.path}',
                                  textAlign: TextAlign.center,
                                ),
                                TextButton(
                                  onPressed: () => _showDocumentLocation(file),
                                  child: const Text('Show Location'),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectAndDownloadImage() async {
    try {
      final pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          _imageFiles.addAll(
              pickedFiles.whereType<XFile>().map((file) => File(file.path)));
        });
        await _saveImagesToDirectory(pickedFiles
            .whereType<XFile>()
            .map((file) => File(file.path))
            .toList());
        await prefs.setStringList(
            'imageFiles', _imageFiles.map((file) => file.path).toList());
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  Future<void> _selectAndDownloadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: true,
      );
      if (result != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<File> pickedFiles =
            result.paths!.map((path) => File(path!)).toList();
        setState(() {
          _documentFiles.addAll(pickedFiles);
        });
        await _saveDocumentsToDirectory(pickedFiles);
        await prefs.setStringList(
            'documentFiles', _documentFiles.map((file) => file.path).toList());
      } else {
        print('No documents selected');
      }
    } catch (e) {
      print('Error selecting documents: $e');
    }
  }

  Future<void> _saveImagesToDirectory(List<File> imageFiles) async {
    try {
      Directory? directory = await getDownloadsDirectory();
      if (directory != null) {
        for (File imageFile in imageFiles) {
          String fileName = imageFile.path.split('/').last;
          String filePath = '${directory.path}/$fileName';
          await imageFile.copy(filePath);
        }
      } else {
        print('Error: Download directory is null');
      }
    } catch (e) {
      print('Error saving images: $e');
    }
  }

  Future<void> _saveDocumentsToDirectory(List<File> documentFiles) async {
    try {
      Directory? directory = await getDownloadsDirectory();
      if (directory != null) {
        for (File documentFile in documentFiles) {
          String fileName = documentFile.path.split('/').last;
          String filePath = '${directory.path}/$fileName';
          await documentFile.copy(filePath);
        }
      } else {
        print('Error: Download directory is null');
      }
    } catch (e) {
      print('Error saving documents: $e');
    }
  }

  void _showDocumentLocation(File documentFile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Document saved at: ${documentFile.path}'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            _openDocument(documentFile);
          },
        ),
      ),
    );
  }

  Future<void> _openDocument(File documentFile) async {
    try {
      // Use the open_file package to open the document
      await OpenFile.open(documentFile.path);
    } catch (e) {
      print('Error opening document: $e');
    }
  }

  Widget _buildButtonWithIcon({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
