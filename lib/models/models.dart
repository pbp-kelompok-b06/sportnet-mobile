// --- DATA MODELS ---
// Dummy data Sementara supaya homepage nya ada dulu, ganti nanti

class Event {
  final String name;
  final String datePlace;
  final String category;
  final String type; // e.g., 'Match', 'Training'
  final String imageUrl;
  final bool isFree;

  Event({
    required this.name,
    required this.datePlace,
    required this.category,
    required this.type,
    required this.imageUrl,
    this.isFree = false,
  });
}

// --- DUMMY DATA ---

final List<Event> dummyEvents = [
  Event(
    name: 'Football Cup',
    datePlace: 'Oct 25, 2024, Field A',
    category: 'Football',
    type: 'Match',
    imageUrl: 'https://placehold.co/400x300/F0544F/white?text=Soccer',
    isFree: true,
  ),
  Event(
    name: 'Yoga Retreat',
    datePlace: 'Nov 1, 2024, Studio B',
    category: 'Wellness',
    type: 'Training',
    imageUrl: 'https://placehold.co/400x300/FF7F50/white?text=Yoga',
    isFree: false,
  ),
  Event(
    name: 'Badminton Fun',
    datePlace: 'Oct 28, 2024, Court C',
    category: 'Racket',
    type: 'Match',
    imageUrl: 'https://placehold.co/400x300/D4A62C/white?text=Badminton',
    isFree: true,
  ),
  Event(
    name: 'Basketball League',
    datePlace: 'Oct 30, 2024, Gym D',
    category: 'Ball Sport',
    type: 'Tournament',
    imageUrl: 'https://placehold.co/400x300/FF6347/white?text=Basketball',
    isFree: false,
  ),
  Event(
    name: 'Tennis Clash',
    datePlace: 'Oct 26, 2024, Court E',
    category: 'Racket',
    type: 'Match',
    imageUrl: 'https://placehold.co/400x300/E9967A/white?text=Tennis',
    isFree: true,
  ),
  Event(
    name: 'Cycling Race',
    datePlace: 'Nov 5, 2024, Park Road',
    category: 'Endurance',
    type: 'Race',
    imageUrl: 'https://placehold.co/400x300/4682B4/white?text=Cycling',
    isFree: false,
  ),
];