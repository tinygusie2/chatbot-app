
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: ChatScreen(toggleTheme: toggleTheme),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final Function(bool) toggleTheme;

  ChatScreen({required this.toggleTheme});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  String _userName = '';
  bool _isDarkMode = false;
  final Map<String, List<String>> _movieGenres = {
  'actie': ['Terminator', 'Die Hard', 'Rambo', 'The Matrix', 'Gladiator', 'The Dark Knight', 'Inception', 'Mad Max: Fury Road', 'The Avengers', 'Jurassic Park', 'Indiana Jones', 'Braveheart', 'Mission: Impossible', 'The Bourne Identity', '300', 'Avatar', 'Fast & Furious', 'The Terminator', 'Top Gun', 'Kill Bill'],
  'comedy': ['The Hangover', 'Superbad', 'Anchorman', 'Dumb and Dumber', 'Bridesmaids', 'Pineapple Express', 'Deadpool', 'Super Troopers', 'Napoleon Dynamite', 'Austin Powers', 'Airplane!', 'The Naked Gun', 'Ferris Bueller\'s Day Off', 'Groundhog Day', 'Caddyshack', 'Monty Python and the Holy Grail', 'Zoolander', 'Old School', 'Wedding Crashers', 'Elf'],
  'drama': ['The Shawshank Redemption', 'Forrest Gump', 'Titanic', 'Schindler\'s List', 'The Godfather', 'The Green Mile', 'Fight Club', 'The Departed', 'Good Will Hunting', 'A Beautiful Mind', 'The Prestige', 'American History X', 'The Social Network', '12 Angry Men', 'The Pianist', 'The Revenant', 'Casablanca', 'American Beauty', 'Whiplash', 'The Silence of the Lambs'],
  'thriller': ['The Silence of the Lambs', 'Se7en', 'Gone Girl', 'Shutter Island', 'Memento', 'The Usual Suspects', 'Prisoners', 'The Sixth Sense', 'Black Swan', 'Zodiac', 'Heat', 'Seven Samurai', 'Vertigo', 'No Country for Old Men', 'The Girl with the Dragon Tattoo', 'Reservoir Dogs', 'The Fugitive', 'The Game', 'The Others', 'Sicario'],
  'horror': ['The Exorcist', 'Psycho', 'The Shining', 'Halloween', 'A Nightmare on Elm Street', 'The Conjuring', 'Get Out', 'Hereditary', 'Saw', 'It', 'The Babadook', 'Paranormal Activity', 'The Blair Witch Project', 'Poltergeist', 'The Ring', 'Night of the Living Dead', 'The Texas Chain Saw Massacre', 'Rosemary\'s Baby', 'Cabin in the Woods', 'The Sixth Sense'],
  'science fiction': ['Star Wars', 'Blade Runner', 'Interstellar', 'Avatar', 'Back to the Future', 'E.T. the Extra-Terrestrial', 'Alien', 'The Terminator', 'The Martian', 'District 9', 'The Fifth Element', 'Close Encounters of the Third Kind', 'Jurassic Park', 'Minority Report', '2001: A Space Odyssey', 'The Matrix', 'Arrival', 'The War of the Worlds', 'Tron', 'The Day the Earth Stood Still'],
  'romantiek': ['Titanic', 'The Notebook', 'Pretty Woman', 'Romeo + Juliet', 'La La Land', 'The Fault in Our Stars', 'Eternal Sunshine of the Spotless Mind', '500 Days of Summer', 'Pride & Prejudice', 'Crazy Rich Asians', 'The Princess Bride', 'When Harry Met Sally', 'Love Actually', 'Notting Hill', 'The Shape of Water', 'Brokeback Mountain', 'Casablanca', 'Ghost', 'The Holiday', 'Before Sunrise'],
  'animatie': ['Toy Story', 'Frozen', 'Finding Nemo', 'The Lion King', 'Shrek', 'Up', 'WALL-E', 'Spirited Away', 'Ratatouille', 'How to Train Your Dragon', 'Inside Out', 'Coco', 'The Incredibles', 'Moana', 'Zootopia', 'Kung Fu Panda', 'Despicable Me', 'The Nightmare Before Christmas', 'Tangled', 'Big Hero 6'],
  'fantasie': ['The Lord of the Rings', 'Harry Potter', 'The Hobbit', 'Pan\'s Labyrinth', 'Stardust', 'Alice in Wonderland', 'The Chronicles of Narnia', 'The Princess Bride', 'Willow', 'The NeverEnding Story', 'The Wizard of Oz', 'Labyrinth', 'The Dark Crystal', 'Legend', 'The Golden Compass', 'Eragon', 'Maleficent', 'The Secret Garden', 'Pirates of the Caribbean', 'The Mummy'],
  'mysterie': ['Knives Out', 'Murder on the Orient Express', 'The Da Vinci Code', 'Sherlock Holmes', 'Gone Girl', 'The Girl with the Dragon Tattoo', 'Mystic River', 'The Sixth Sense', 'Prisoners', 'Chinatown', 'The Prestige', 'Zodiac', 'The Bone Collector', 'Shutter Island', 'Se7en', 'Insomnia', 'The Fugitive', 'The Others', 'Identity', 'Memento'],
  'musical': ['The Sound of Music', 'Singin\' in the Rain', 'Mary Poppins', 'The Wizard of Oz', 'Grease', 'Chicago', 'Moulin Rouge!', 'La La Land', 'West Side Story', 'Les Misérables', 'The Lion King', 'Beauty and the Beast', 'Frozen', 'The Greatest Showman', 'Hamilton', 'Annie', 'Cabaret', 'Dreamgirls', 'Sweeney Todd', 'The Phantom of the Opera'],
};


  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadThemeMode();
  }

  _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = (prefs.getString('userName') ?? '');
      if (_userName.isNotEmpty) {
        _messages.insert(0, Message(text: 'Leuk je weer te zien $_userName!', isCurrentUser: false));
      } else {
        _askName();
      }
    });
  }

  _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = (prefs.getBool('isDarkMode') ?? false);
    });
  }

  _saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', userName);
  }

  _saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  void _askName() {
    _messages.insert(0, Message(text: 'Hoe moet ik je noemen?', isCurrentUser: false));
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _saveThemeMode(_isDarkMode);
      widget.toggleTheme(_isDarkMode);
    });
  }

  void _changeUserName() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verander je naam'),
          content: TextField(
            controller: TextEditingController()..text = _userName,
            onChanged: (newName) {
              _userName = newName;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Opslaan'),
              onPressed: () {
                _saveUserName(_userName);
                Navigator.of(context).pop();
                // Optionally, you can display a message to confirm the name change
              },
            ),
            TextButton(
              child: const Text('Terug'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSubmitted(String text) {
  _controller.clear();
  setState(() {
    if (_userName.isEmpty) {
      _userName = text;
      _saveUserName(_userName);
      _messages.insert(0, Message(text: 'Hallo $_userName, leuk je te ontmoeten!', isCurrentUser: false));
    } else {
      Message message = Message(
        text: text,
        isCurrentUser: true,
      );
      _messages.insert(0, message);

      // Voeg hier je chat logica toe
      Message response = _generateSmallTalkResponse(text);

      // Check if the user entered a movie genre
      if (_movieGenres.containsKey(text.toLowerCase())) {
        List<String> moviesInGenre = _movieGenres[text.toLowerCase()] ?? [];
        if (moviesInGenre.isNotEmpty) {
          // Pick a random movie from the genre
          String randomMovie = moviesInGenre[Random().nextInt(moviesInGenre.length)];
          _messages.insert(0, Message(text: 'Een willekeurige film uit het genre $text: $randomMovie', isCurrentUser: false));
          return; // Skip adding the default fallback message
        } else {
          _messages.insert(0, Message(text: 'Er zijn geen films beschikbaar in het genre $text', isCurrentUser: false));
        }
      }

      _messages.insert(0, response);

      // Als de chatbot een vraag stelt, toon dan een dialoogvenster voor ja/nee antwoord
      if (_isQuestion(response.text)) {
        _showYesNoDialog(response.text);
      }
    }
  });
}


  bool _isQuestion(String text) {
    // Eenvoudige check om te zien of de tekst een vraag is
    return text.endsWith('?');
  }

  void _showYesNoDialog(String question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Beantwoord de vraag'),
          content: Text(question),
          actions: <Widget>[
            FilledButton(
              child: const Text('Ja'),
              onPressed: () {
                Navigator.of(context).pop();
                _handleSubmitted('Ja');
              },
            ),
            FilledButton(
              child: const Text('Nee'),
              onPressed: () {
                Navigator.of(context).pop();
                _handleSubmitted('Nee');
              },
            ),
          ],
        );
      },
    );
  }

  Message _generateSmallTalkResponse(String text) {
    // Hier kun je een uitgebreide reeks small talk-reacties toevoegen
    // Voorbeeld:
    if (text.toLowerCase().contains('hoe gaat het')) {
      return Message(
        text: 'Met mij gaat het altijd goed, dank je! Hoe gaat het met jou, $_userName? 😀',
        isCurrentUser: false,
      );
    } else if (text.toLowerCase().contains('wat ben je aan het doen')) {
      final randomBool = Random().nextBool();
      return Message(
        text: randomBool 
          ? 'Ik ben aan het chatten met jou. Wat kan ik voor je doen? 😊'
          : (Random().nextBool() 
              ? 'Ik leer en groei met elke conversatie! 💡'
              : 'Ik ben altijd klaar om te helpen of te praten. 😄'),
        isCurrentUser: false,
      );
    } else if (text.toLowerCase().contains('slecht') || text.toLowerCase().contains('vervelend')) {
      return Message(
        text: 'Dat klinkt vervelend. Hopelijk kan ik je opvrolijken! 😔',
        isCurrentUser: false,
      );
    } else if (text.toLowerCase().contains('hallo') || text.toLowerCase().contains('hey')) {
      final randomBool = Random().nextBool(); // Generate random true/false
      return Message(
        text: randomBool
          ? 'Hey, Wat kan ik voor je doen? 😊'
          : 'Hallo!, hoe gaat het met jou? 👋',
        isCurrentUser: false,
      );
      } else if (text.toLowerCase().contains('wat kun je doen') || text.toLowerCase().contains('wat doe je als chatbot')) {
      final randomBool = Random().nextBool(); // Generate random true/false
      return Message(
        text: randomBool
          ? 'Ik kan je helpen met je problemen en er voor je zijn.😊'
          : 'hier zitten en wachten to er iemand met mij praat!',
        isCurrentUser: false,
      );
    } else if (text.toLowerCase().contains('weer')) {
      return Message(
        text: 'Het weer is onvoorspelbaar tegenwoordig. Wat is jouw favoriete seizoen? ☀️❄️🍂',
        isCurrentUser: false,
      );
    } else if (text.toLowerCase().contains('goed')) {
      return Message(
        text: 'dat is fijn om te horen! 😄',
        isCurrentUser: false,
      );
    } else if (text.toLowerCase().contains('hoe heet ik?')) {
      return Message(
        text: 'jij heet $_userName! 🤖',
        isCurrentUser: false,
      );
    } else if (text.toLowerCase().contains('hallo')) {
      return Message(
        text: 'Hallo, Wat kan ik voor je doen? 😊',
        isCurrentUser: false,
      );
    } else if (text.toLowerCase().contains('vertel iets over jezelf')) {
      return Message(
        text: 'Ik ben een chatbot gemaakt in Flutter. Ik houd ervan om te leren en te groeien met elke conversatie! 🚀',
        isCurrentUser: false,
      );
    } else if (text.toLowerCase().contains('wat is je favoriete kleur?')) {
      return Message(
        text: 'Ik heb niet echt een favoriete kleur, maar blauw ziet er altijd goed uit in apps, vind je niet? 💙',
        isCurrentUser: false,
      );
    } else if (text.toLowerCase().contains('wat is je favoriete eten?')) {
      return Message(
        text: 'Als chatbot eet ik geen voedsel, maar ik kan je helpen een recept te vinden als je wilt! 🍲🥗🍰',
        isCurrentUser: false,
      );
    } else if (text.toLowerCase().contains('vertel een grap')) {
      return Message(
        text: 'Twee paraplu’s staan te drogen bij de deur. Dan komt er een wandelstok voorbij. ‘Zo, die durft’, zegt een van de paraplu’s. ‘Zo in z’n blootje naar buiten.’ 😄😆',
        isCurrentUser: false,
      );
    } else if (text.toLowerCase().contains('film') || text.toLowerCase().contains('film voorstellen')) {
      return Message(
        text: 'Welk genre zoek je? Beschikbare genres zijn: ${_movieGenres.keys.join(", ")}',
        isCurrentUser: false,
      );
    } else {
      // Voeg meer condities toe voor andere small talk-reacties
      return Message(
        text: ' Cool! Is er nog iets waar je over wilt praten? 😊',
        isCurrentUser: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Chat App'),
            SizedBox(width: 8), // Add some spacing between the title and "Made by Guus"
            Text(
              'Made by Guus',
              style: TextStyle(fontSize: 12), // Adjust font size as needed
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.person), // Changed icon to person
            onPressed: _changeUserName,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => ChatBubble(
                message: _messages[index].text,
                isCurrentUser: _messages[index].isCurrentUser,
                bubbleColor: getBubbleColor(_messages[index].isCurrentUser),
              ),
              itemCount: _messages.length,
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Color getBubbleColor(bool isCurrentUser) {
    return isCurrentUser ? Colors.red : Colors.green;
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).secondaryHeaderColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _controller,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(hintText: 'Stuur een bericht'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  String text;
  bool isCurrentUser;
  Message({required this.text, required this.isCurrentUser});
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final Color bubbleColor;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    required this.bubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: isCurrentUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilledButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const FilledButton({
    Key? key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      ),
      child: child,
    );
  }
}


