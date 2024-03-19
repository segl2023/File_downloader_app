//import 'dart:html';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class UploadedFile extends StatefulWidget {
  const UploadedFile({Key? key}) : super(key: key);

  @override
  State<UploadedFile> createState() => _UploadedFileState();
}

class _UploadedFileState extends State<UploadedFile> {
  // Function to handle file upload

  File? _imageFile;
  File? _documentFile;

  bool _isImageSaving = false;
  bool _isDocumentDownloading = false;
  bool _isDownloading = false; // Track download status

  void uploadFile(String fileType) async {
    try {
      // Getting directory path using path_provider package
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = directory.path;

      switch (fileType) {
        case 'image':
          // Implement logic for other file types...
          String imagePath = '$filePath/image.jpg';
          File imageFile = File(imagePath);
          if (fileType == 'image') {
            final XFile? pickedFile =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              // Get the file path of the selected image
              String imagePath = pickedFile.path;
            } else {
              print('No image selected');
            }
          } else {
            print('Selected file type is not supported');
          }
          break;

        case 'documents':
          // Implemet logic to upload and download documents
          try {
            // Pick document files from device storage
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
              allowMultiple: true, // Allow picking multiple files
            );

            if (result != null) {
              List<PlatformFile> files = result.files;

              // Loop through selected files and upload each one
              for (PlatformFile file in files) {
                String filePath = file.path!;
                File documentFile = File(filePath);

                // Specify the destination directory path
                String destinationDirectory = '$filePath/documents';

                // Create the destination directory if it doesn't exist
                Directory destinationDir = Directory(destinationDirectory);
                if (!await destinationDir.exists()) {
                  await destinationDir.create(recursive: true);
                  print('Destination directory created: $destinationDirectory');
                }

                String destinationPath = '$destinationDirectory/${file.name}';

                // Copy the selected document file to the destination directory
                await documentFile.copy(destinationPath);

                // Display a message indicating successful upload
                print('Document file uploaded successfully: $destinationPath');
              }
            } else {
              print('No documents selected');
            }
          } catch (e) {
            print('Error uploading documents: $e');
          }
          break;
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to handle image selection and download
  Future<void> _selectAndDownloadImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        await _saveImageToDirectory(_imageFile!);
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  // Function to handle document selection and download - method 1
  Future<void> _selectAndDownloadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );
      if (result != null) {
        setState(() {
          _documentFile = File(result.files.single.path!);
        });
        await _saveDocumentToDirectory(_documentFile!);
      } else {
        print('No document selected');
      }
    } catch (e) {
      print('Error selecting document: $e');
    }
  }

  // Function to handle downloading the selected document - method second
  Future<void> _downloadDocument() async {
    setState(() {
      _isDownloading = true; // Set download status to true
    });

    if (_documentFile != null) {
      // Simulate download success or failure
      bool downloadSuccess = true; // Replace this with actual download logic

      // Simulate download delay
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isDownloading = false; // Reset download status
      });

      if (downloadSuccess) {
        print('Document downloaded successfully: ${_documentFile!.path}');
      } else {
        print('Document download failed');
      }
    } else {
      print('No document selected');
    }
  }

  // Function to save the selected image to the device's download folder
  Future<void> _saveImageToDirectory(File imageFile) async {
    try {
      // Set the loading state for image saving
      setState(() {
        _isImageSaving = true;
      });

      Directory? directory = await getDownloadsDirectory();
      if (directory != null) {
        String fileName = 'image.jpg'; // File name
        String filePath = '${directory.path}/$fileName'; // Define the file path
        await imageFile.copy(filePath); // Copy image to the download folder
        print('Image saved to: $filePath');
      } else {
        print('Error: Download directory is null');
      }

      // Reset the loading state for image saving
      setState(() {
        _isImageSaving = false;
      });
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  // Function to save the selected document to the device's download folder
  Future<void> _saveDocumentToDirectory(File documentFile) async {
    try {
      // Set the loading state for document saving
      setState(() {
        _isDocumentDownloading = true;
      });

      // Get the path to the device's download folder
      Directory? downloadDir = await getDownloadsDirectory();
      if (downloadDir != null) {
        // Define the destination path for the document
        String fileName = documentFile.path.split('/').last;
        String destinationPath = '${downloadDir.path}/$fileName';

        // Copy the document to the download folder
        await documentFile.copy(destinationPath);

        // Reset the loading state for document saving
        setState(() {
          _isDocumentDownloading = false;
        });

        print('Document saved to: $destinationPath');
      } else {
        print('Error: Download directory is null');
      }
    } catch (e) {
      print('Error saving document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Upload Files'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Add a button to select and download a document
                _buildButtonWithIcon(
                  onPressed: _selectAndDownloadImage,
                  label: 'Select and Download Image',
                  icon: Icons.download,
                ),
                if (_imageFile != null)
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: Image.file(
                      _imageFile!,
                      width: 200,
                      height: 200,
                    ),
                  ),

                // Add a button to select and download a document
                ElevatedButton(
                  onPressed: _selectAndDownloadDocument,
                  child: const Text('Select and Download Document'),
                ),
                // Display the selected document
                if (_documentFile != null)
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: Text(
                      'Selected Document: ${_documentFile!.path}',
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Button to trigger document download
                ElevatedButton(
                  onPressed: _downloadDocument,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isDownloading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Icon(Icons.download),
                      const SizedBox(width: 8),
                      Text(
                        _isDownloading ? 'Downloading...' : 'Download Document',
                        style: TextStyle(
                          color: _isDownloading ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  // const Text('Download Document'),
                ),
              ],
            ),
          ),
        ));
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
