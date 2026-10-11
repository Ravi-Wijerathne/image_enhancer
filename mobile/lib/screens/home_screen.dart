import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  File? _originalImage;
  File? _enhancedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _originalImage = File(image.path);
        _enhancedImage = null; // Reset enhanced image when a new one is picked
      });
    }
  }

  Future<void> _enhanceImage() async {
    if (_originalImage == null) return;

    setState(() {
      _isLoading = true;
    });

    final enhanced = await ApiService.enhanceImage(_originalImage!);

    setState(() {
      _enhancedImage = enhanced;
      _isLoading = false;
    });
    
    if (enhanced == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to enhance image. Please check if backend is running on 127.0.0.1:8000.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _downloadImage() async {
    if (_enhancedImage == null) return;
    
    final String fileName = 'enhanced_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    try {
      final FileSaveLocation? result = await getSaveLocation(suggestedName: fileName);
      if (result == null) {
        return; // User canceled
      }
      
      await _enhancedImage!.copy(result.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark mode base
      appBar: AppBar(
        title: const Text(
          'AI Enhancer',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_originalImage == null)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded, size: 80, color: Colors.white54),
                        SizedBox(height: 16),
                        Text(
                          'Tap to select an image',
                          style: TextStyle(color: Colors.white54, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_originalImage != null && _enhancedImage == null && !_isLoading)
                Column(
                  children: [
                    Text('Original', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(_originalImage!, height: 300, fit: BoxFit.cover),
                    ),
                  ],
                )
              else if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2575FC)),
                    ),
                  ),
                )
              else if (_enhancedImage != null)
                Column(
                  children: [
                    const Text('Swipe to compare', style: TextStyle(color: Colors.white54, fontSize: 16)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BeforeAfterSlider(
                        originalImage: _originalImage!,
                        enhancedImage: _enhancedImage!,
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 40),
              
              if (_originalImage != null && !_isLoading && _enhancedImage == null)
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton(
                    onPressed: _enhanceImage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      '✨ Enhance Now',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                
              if (_enhancedImage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43A047), Color(0xFF1DE9B6)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _downloadImage,
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text(
                      'Download Image',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),

              if (_originalImage != null && !_isLoading)
                TextButton(
                  onPressed: _pickImage,
                  child: const Text('Choose Another Image', style: TextStyle(color: Colors.white70)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BeforeAfterSlider extends StatefulWidget {
  final File originalImage;
  final File enhancedImage;

  const BeforeAfterSlider({
    super.key,
    required this.originalImage,
    required this.enhancedImage,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _position = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      return GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta.dx / width;
            _position = _position.clamp(0.0, 1.0);
          });
        },
        child: SizedBox(
          height: 350,
          child: Stack(
            children: [
              // Enhanced Image (Bottom)
              Positioned.fill(
                child: Image.file(
                  widget.enhancedImage,
                  fit: BoxFit.cover,
                ),
              ),
              // Original Image (Clipped, Top)
              Positioned.fill(
                child: ClipRect(
                  clipper: _RectClipper(_position),
                  child: Image.file(
                    widget.originalImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Slider handle
              Positioned(
                left: width * _position - 20, // 20 is half the handle width
                top: 0,
                bottom: 0,
                child: Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 4,
                        color: Colors.white,
                      ),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black45, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.compare_arrows, color: Colors.black, size: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _RectClipper extends CustomClipper<Rect> {
  final double widthFactor;
  _RectClipper(this.widthFactor);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * widthFactor, size.height);
  }

  @override
  bool shouldReclip(_RectClipper oldClipper) {
    return oldClipper.widthFactor != widthFactor;
  }
}
