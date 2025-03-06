import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../utils/constants.dart';
import '../services/chatgpt_service.dart';
import '../services/ai_service.dart';
import '../services/supabase_service.dart';
import '../utils/url_launcher_utils.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Future<List<ProductRecommendation>>? _recommendationsFuture;
  bool _isGenerating = false;
  String? _generationError;
  bool _isSaving = false;
  bool _designSaved = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    
    // If we don't have a generated image yet, generate one
    if (appState.generatedImageUrl == null && appState.image != null) {
      _generateImage(appState);
    }
    
    // Fetch recommendations using the selected style and room type
    _recommendationsFuture = ChatGPTService.getProductRecommendations(
      style: appState.style ?? "Modern",
      roomType: appState.roomType ?? "Living Room",
    );
  }
  
  Future<void> _generateImage(AppState appState) async {
    setState(() {
      _isGenerating = true;
      _generationError = null;
    });
    
    try {
      final generatedUrl = await AIService.generateDesign(
        image: appState.image!,
        roomType: appState.roomType,
        style: appState.style,
        featureType: appState.featureType,
        prompt: appState.prompt,
        colorPalette: appState.colorPalette,
        buildingType: appState.buildingType,
      );
      
      if (generatedUrl != null) {
        appState.setGeneratedImageUrl(generatedUrl);
        setState(() {
          _isGenerating = false;
        });
      } else {
        print("Failed to generate image: No URL returned");
        setState(() {
          _isGenerating = false;
          _generationError = "Failed to generate image. Please try again.";
        });
      }
    } catch (e) {
      print("Error generating image: $e");
      setState(() {
        _isGenerating = false;
        _generationError = "Error: $e";
      });
    }
  }

  Future<void> _saveDesign() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    if (appState.generatedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No design to save yet. Please generate a design first.')),
      );
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      await SupabaseService().saveDesign(
        deviceId: appState.deviceId,
        roomType: appState.roomType ?? 'Room',
        style: appState.style ?? 'Style',
        imageUrl: appState.generatedImageUrl!,
        featureType: appState.featureType ?? 'Interior Design',
        prompt: appState.prompt,
      );
      
      setState(() {
        _isSaving = false;
        _designSaved = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Design saved successfully!')),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save design: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        actions: [
          if (_isGenerating)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              )),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Regenerate Design',
              onPressed: () {
                _generateImage(appState);
              },
            ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'View Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Before vs. After",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final imageWidth = (constraints.maxWidth - 8) / 2;
              final imageHeight = imageWidth * 0.75;
              
              return Row(
                children: [
                  if (appState.image != null)
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Before", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              appState.image!,
                              height: imageHeight,
                              width: imageWidth,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        const Text("After", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (_isGenerating)
                          Container(
                            height: imageHeight,
                            width: imageWidth,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_generationError != null)
                          Container(
                            height: imageHeight,
                            width: imageWidth,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _generationError!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ),
                          )
                        else if (appState.generatedImageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              appState.generatedImageUrl!,
                              height: imageHeight,
                              width: imageWidth,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: imageHeight,
                                  width: imageWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            height: imageHeight,
                            width: imageWidth,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text("No image generated yet"),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isSaving || _isGenerating ? null : _saveDesign,
                icon: _isSaving
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_designSaved ? 'Saved!' : 'Save Design'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  appState.resetState();
                  Navigator.pushNamedAndRemoveUntil(
                    context, 
                    '/', 
                    (route) => false
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('New Design'),
              ),
            ],
          ),
          if (appState.featureType == 'Interior Design' || appState.featureType == 'Exterior Design')
            FutureBuilder<List<ProductRecommendation>>(
              future: _recommendationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Text(
                        'Error loading recommendations: ${snapshot.error}',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      const Text(
                        "Product Recommendations",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...snapshot.data!.map((product) => _buildProductCard(product)),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductRecommendation product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(product.description),
            const SizedBox(height: 8),
            Text(
              'Price: ${product.price}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (product.url != null)    
              TextButton(
                onPressed: () => UrlLauncherUtils.launchURL(context, product.url!),
                child: const Text('View Product'),
              ),
          ],
        ),
      ),
    );
  }
} 