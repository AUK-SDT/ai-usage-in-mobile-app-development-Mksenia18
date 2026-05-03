import 'package:flutter/material.dart';
import 'ai_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SummaryScreen());
  }
}

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final TextEditingController controller = TextEditingController();
  String result = "";
  bool isLoading = false;

  final aiService = AIService("");

  void summarize() async {
    setState(() => isLoading = true);

    try {
      final response = await aiService.summarizeText(controller.text);
      setState(() => result = response);
    } catch (e) {
      setState(() => result = "Error occurred");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Summarizer")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter text...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: summarize, child: Text("Summarize")),
            SizedBox(height: 20),
            isLoading ? CircularProgressIndicator() : Text(result),
          ],
        ),
      ),
    );
  }
}
