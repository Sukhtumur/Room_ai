import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../utils/constants.dart';
import '../services/chatgpt_service.dart';
import '../services/ai_service.dart';
import '../services/supabase_service.dart';
import '../utils/url_launcher_utils.dart';

class ResultsScreen extends StatefulWidget {
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
        roomType: appState.roomType ?? "Living Room",
        style: appState.style ?? "Modern",
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
        SnackBar(content: Text('No design to save yet. Please generate a design first.')),
      );
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      await SupabaseService().saveDesign(
        userId: appState.userId,
        roomType: appState.roomType ?? 'Room',
        style: appState.style ?? 'Style',
        imageUrl: appState.generatedImageUrl!,
      );
      
      setState(() {
        _isSaving = false;
        _designSaved = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Design saved successfully!')),
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
        title: Text(AppConstants.appTitle),
        actions: [
          if (_isGenerating)
            Padding(
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
              icon: Icon(Icons.refresh),
              tooltip: 'Regenerate Design',
              onPressed: () {
                _generateImage(appState);
              },
            ),
          IconButton(
            icon: Icon(Icons.person),
            tooltip: 'View Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Before vs. After",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                if (appState.image != null)
                  Expanded(
                    child: Column(
                      children: [
                        Text("Before", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            appState.image!,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Text("After", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      if (appState.generatedImageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            appState.generatedImageUrl!,
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                color: Colors.grey[200],
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
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_generationError != null)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red, size: 40),
                                      SizedBox(height: 8),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          _generationError!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          _generateImage(appState);
                                        },
                                        child: Text("Try Again"),
                                      ),
                                    ],
                                  )
                                else if (_isGenerating)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text("Generating design...", 
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.image, color: Colors.grey, size: 40),
                                      SizedBox(height: 8),
                                      Text("Ready to generate", 
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          _generateImage(appState);
                                        },
                                        child: Text("Generate Design"),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              "Product Recommendations",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            FutureBuilder<List<ProductRecommendation>>(
              future: _recommendationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Error loading recommendations: ${snapshot.error}",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                final recommendations = snapshot.data ?? [];
                if (recommendations.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "No product recommendations available. We're working on it!",
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return Column(
                  children: recommendations.map((rec) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          rec.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rec.description),
                              SizedBox(height: 8),
                              Text(
                                "Price: ${rec.price}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          UrlLauncherUtils.launchURL(context, rec.url);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            if (appState.generatedImageUrl != null)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  onPressed: _isSaving || _designSaved ? null : _saveDesign,
                  icon: _isSaving 
                    ? SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      ) 
                    : Icon(_designSaved ? Icons.check : Icons.save),
                  label: Text(_designSaved ? 'Design Saved' : 'Save Design'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 