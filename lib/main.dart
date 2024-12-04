import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _latestMovies = [];
  List _popularMovies = [];
  List _searchResults = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final latestResponse = await http
        .get(Uri.parse('http://www.omdbapi.com/?apikey=8f6fe79f&s=latest'));
    if (latestResponse.statusCode == 200) {
      setState(() {
        _latestMovies = json.decode(latestResponse.body)['Search'];
      });
    } else {
      throw Exception('Failed to load latest movies');
    }

    final popularResponse = await http
        .get(Uri.parse('http://www.omdbapi.com/?apikey=8f6fe79f&s=batman'));
    if (popularResponse.statusCode == 200) {
      setState(() {
        _popularMovies = json.decode(popularResponse.body)['Search'];
      });
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<void> searchMovies(String query) async {
    setState(() {
      _isSearching = true;
    });
    final response = await http
        .get(Uri.parse('http://www.omdbapi.com/?apikey=8f6fe79f&s=$query'));
    if (response.statusCode == 200) {
      setState(() {
        _searchResults = json.decode(response.body)['Search'];
      });
    } else {
      throw Exception('Failed to load search results');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      buildHomePage(context),
      GenrePage(genre: 'horror'),
      GenrePage(genre: 'action'),
      GenrePage(genre: 'kids'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Ndelok Film'),
        backgroundColor: Colors.blue,
        elevation: 10,
        shadowColor: Colors.blueGrey,
        leading: _isSearching
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _searchResults.clear();
                  });
                },
              )
            : null,
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.theater_comedy_rounded),
            label: 'Horror',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_creation),
            label: 'Action',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Kids',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Warna tombol aktif
        unselectedItemColor: Colors.grey, // Warna tombol tidak aktif
        backgroundColor: Colors.blue, // Warna latar belakang navbar
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildHomePage(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Film apa yang ingin kamu tonton?',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 18, 0, 0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari film...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    searchMovies(_searchController.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            // Search Results
            _isSearching
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hasil Pencarian',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final movie = _searchResults[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieDetailPage(
                                        movieId: movie['imdbID']),
                                  ),
                                );
                              },
                              child: MovieCard(movie: movie),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Film Terbaru (Latest Movies)
                      Text(
                        'Film Terbaru',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _latestMovies.length,
                          itemBuilder: (context, index) {
                            final movie = _latestMovies[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieDetailPage(
                                        movieId: movie['imdbID']),
                                  ),
                                );
                              },
                              child: MovieCard(movie: movie),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      // Film Populer (Popular Movies)
                      Text(
                        'Film Populer',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _popularMovies.length,
                          itemBuilder: (context, index) {
                            final movie = _popularMovies[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieDetailPage(
                                        movieId: movie['imdbID']),
                                  ),
                                );
                              },
                              child: MovieCard(movie: movie),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final dynamic movie;

  MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      shadowColor: Colors.redAccent[700],
      child: Container(
        width: 120, // Lebar card
        height: 190, // Tinggi card
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                movie['Poster'],
                fit: BoxFit.cover,
                height: 160, // Gambar disesuaikan dengan ukuran card
                width: double.infinity,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                movie['Title'],
                style: TextStyle(
                  fontSize: 12, // Ukuran teks lebih kecil agar pas dengan card
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center, // Teks di tengah
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieDetailPage extends StatefulWidget {
  final String movieId;

  MovieDetailPage({required this.movieId});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Map<String, dynamic>? _movieDetails;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
  }

  Future<void> fetchMovieDetails() async {
    final response = await http.get(Uri.parse(
        'http://www.omdbapi.com/?apikey=8f6fe79f&i=${widget.movieId}&plot=full'));
    if (response.statusCode == 200) {
      setState(() {
        _movieDetails = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_movieDetails?['Title'] ?? 'Loading...'),
        backgroundColor: Colors.blue,
        elevation: 10,
        shadowColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: _movieDetails != null
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _movieDetails!['Poster'],
                          height: 300,
                          width: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _movieDetails!['Title'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Year: ${_movieDetails!['Year']}'),
                    SizedBox(height: 8),
                    Text('Genre: ${_movieDetails!['Genre']}'),
                    SizedBox(height: 8),
                    Text('Director: ${_movieDetails!['Director']}'),
                    SizedBox(height: 8),
                    Text('Actors: ${_movieDetails!['Actors']}'),
                    SizedBox(height: 8),
                    Text('Plot: ${_movieDetails!['Plot']}'),
                    SizedBox(height: 8),
                    Text('IMDb Rating: ${_movieDetails!['imdbRating']}'),
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class GenrePage extends StatelessWidget {
  final String genre;

  GenrePage({required this.genre});

  Future<List> fetchGenreMovies(String genre) async {
    final response = await http
        .get(Uri.parse('http://www.omdbapi.com/?apikey=8f6fe79f&s=$genre'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['Search'];
    } else {
      throw Exception('Failed to load movies for genre $genre');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: fetchGenreMovies(genre),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No movies found for genre $genre'));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final movie = snapshot.data![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MovieDetailPage(movieId: movie['imdbID']),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Poster Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            movie['Poster'],
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 80,
                                width: 80,
                                color: Colors.grey,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        // Movie Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie['Title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                movie['Year'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Click for details',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
