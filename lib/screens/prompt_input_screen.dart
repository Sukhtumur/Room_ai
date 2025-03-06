import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class PromptInputScreen extends StatefulWidget {
  const PromptInputScreen({super.key});

  @override
  _PromptInputScreenState createState() => _PromptInputScreenState();
}

class _PromptInputScreenState extends State<PromptInputScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isPromptValid = false;

  @override
  void initState() {
    super.initState();
    _promptController.addListener(_validatePrompt);
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _validatePrompt() {
    setState(() {
      _isPromptValid = _promptController.text.trim().length >= 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final featureType = appState.featureType;
    
    String promptHint = '';
    String promptTitle = '';
    
    switch (featureType) {
      case 'Object Editing':
        promptTitle = 'Describe what to add or remove';
        promptHint = 'E.g., "Remove the coffee table" or "Add a modern sofa"';
        break;
      case 'Paint & Color':
        promptTitle = 'Describe the color changes';
        promptHint = 'E.g., "Paint the walls blue" or "Change the cabinet color to white"';
        break;
      default:
        promptTitle = 'Describe your changes';
        promptHint = 'Enter your instructions for the AI';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(featureType ?? 'Customize'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (appState.image != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(appState.image!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              promptTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: promptHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Be specific about what you want to change in the image.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPromptValid
                    ? () {
                        appState.setPrompt(_promptController.text.trim());
                        Navigator.pushNamed(context, '/results');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Generate Result'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 