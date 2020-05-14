import 'package:flutter/material.dart';
import 'package:music_recommender/models/my_track.dart';
import 'package:music_recommender/utils/database_helper.dart';
import 'package:music_recommender/services/spotify_api.dart';
import 'package:spotify/spotify.dart';

// Home screen of the app that should show the music recommendations
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Temporary spotify helper
  SpotifyHelper spotify = SpotifyHelper();

  // Database helper to save and delete favourite songs
  DatabaseHelper helper = DatabaseHelper();

  // initialize data as an empty Map object
  Map data = {};

  @override
  Widget build(BuildContext context) {

    // Get data from loading screen
    data = data.isNotEmpty ? data : ModalRoute.of(context).settings.arguments;

    // Main widget
    return Scaffold(
      // Bg color
      backgroundColor: Theme.of(context).backgroundColor,
      // App bar
      appBar: AppBar(
        title: Text('Recommendations for you'),
        centerTitle: true,
      ),
      // Main Body
      body: _getListView(),
      // Drawer for navigating between screens
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          // Elements in the drawer
          children: <Widget>[
            // Main drawer header at the top
            DrawerHeader(
              child: Center(
                child: Text(
                  'Welcome to Music Recommender!',
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
              ),
            ),
            // Navigate to recommendations (for refreshing)
            _getDrawerElement(
              'Recommendations',
              'Refresh your recommendations',
              () {
                //Clear stack and push to the route
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            ),
            // Navigate to User Songs
            _getDrawerElement(
              'My Songs',
              'View all my favourite songs',
              () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/user_songs');
              }
            ),
            // Navigate to Search Songs
            _getDrawerElement(
              'Search Songs',
              'Search songs and add to My Songs',
              () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/search');
              }
            )
          ],
        ),
      ),
    );
  }

  Widget _getDrawerElement(String title, String subtitle, Function onTapFunc) {
    // List Tile Widget
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20.0
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontStyle: FontStyle.italic
        ),
      ),
      onTap: onTapFunc,
    );
  }

  Widget _getListView() {
    // get recommendations from Map object
    List<TrackSimple> _recommended = data['recommendations'];
    // If user has no songs in their list
    if (_recommended == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Add songs to get recommendations',
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: 18.0
                )
              ),
            ),
          ],
        )
      );
    }
    // return a list view
    return ListView.builder(
      // Number of items
      itemCount: _recommended.length,
      // Function to be mapped per element
      itemBuilder: (context, index) {
        // Create empty list for artists
        List<String> artistsList = [];
        // Iterate through artists per track
        _recommended[index].artists.forEach((_artist) {
          // Add artist name to artistsList
          artistsList.add(_artist.name);
        });
        // Return widget
        return Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: Card(
            // List tile widget
            child: ListTile(
              // Name of the track
              title: Text(_recommended[index].name),
              // Artists
              subtitle: Text(artistsList.toString().replaceAll('[', '').replaceAll(']', '')),
              // Music Icon
              leading: Icon(Icons.music_note),
              onTap: () {
                // TODO: Go to details screen
                _save(context, _recommended[index].name, _recommended[index].id);
              },
            ),
          ),
        );
      },
    );

  }

  // TODO: Put these in details page, therefore code will not be repeated
  // Save track to database
  _save(BuildContext context, String _name, String _sId) async {
    int result;
    MyTrack _myTrack = MyTrack(_name, _sId);
    result = await helper.insertTrack(_myTrack);

    if (result != 0) {
      // Success
      _showSnackBar(context, 'Added $_name to My Songs');
    } else {
      // failure
      _showSnackBar(context, 'Failed to add $_name');
    }
  }

  // show SnackBar
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

}
