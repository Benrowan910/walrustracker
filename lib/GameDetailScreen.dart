import 'package:flutter/material.dart';
import 'main.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;

  GameDetailScreen({required this.game});

  @override _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  late TextEditingController noteController;
  bool isPlayed = false;

  @override
  void initState(){
    super.initState();
    noteController = TextEditingController(text: widget.game.note);
    isPlayed = widget.game.isPlayed;
  }

    void saveChanges() {
    setState(() {
      widget.game.note = noteController.text;
      widget.game.isPlayed = isPlayed;
    });
    Navigator.pop(context); // Return to the main screen
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Cover Image
            if (widget.game.coverUrl != null)
              Center(
                child: Image.network(
                  widget.game.coverUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, size: 100),
                ),
              ),
            SizedBox(height: 16),
            // Notes TextField
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Write your thoughts about this game...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ),
            SizedBox(height: 16),
            // Played Switch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mark as Played', style: TextStyle(fontSize: 18)),
                  Switch(
                    value: isPlayed,
                    onChanged: (value) {
                      setState(() {
                        isPlayed = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Save Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: saveChanges,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }  
  
  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}
