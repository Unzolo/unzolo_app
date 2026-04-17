class MockPackage {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviewCount;
  final int durationDays;
  final List<String> highlights;
  final List<String> included;
  final List<String> thingsToCarry;
  final List<MockDayItinerary> itinerary;
  final String category;

  const MockPackage({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.durationDays,
    required this.highlights,
    required this.included,
    required this.thingsToCarry,
    required this.itinerary,
    required this.category,
  });
}

class MockDayItinerary {
  final int day;
  final String title;
  final List<String> activities;

  const MockDayItinerary({
    required this.day,
    required this.title,
    required this.activities,
  });
}

class MockUser {
  final String id;
  final String username;
  final String fullName;
  final String avatarUrl;
  final String? location;
  final String? bio;
  final int followersCount;
  final int connectionsCount;
  final List<String> languages;
  final List<String> interests;
  final String? travelStyle;

  const MockUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    this.location,
    this.bio,
    required this.followersCount,
    required this.connectionsCount,
    required this.languages,
    required this.interests,
    this.travelStyle,
  });
}

class MockMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const MockMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });
}

class MockChat {
  final String id;
  final MockUser participant;
  final MockMessage lastMessage;
  final int unreadCount;

  const MockChat({
    required this.id,
    required this.participant,
    required this.lastMessage,
    required this.unreadCount,
  });
}

class MockData {
  MockData._();

  static final currentUser = MockUser(
    id: 'u1',
    username: 'rafeeq',
    fullName: 'Rafeeq',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    location: 'Vadodara, Kerala',
    bio: 'Travel enthusiast | Explorer',
    followersCount: 0,
    connectionsCount: 0,
    languages: ['Malayalam', 'Hindi', 'English'],
    interests: ['Adventure', 'Hiking', 'Photography'],
    travelStyle: 'Solo',
  );

  static final List<MockUser> suggestedUsers = [
    MockUser(
      id: 'u2',
      username: 'priya',
      fullName: 'Priya Sharma',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      location: 'Mumbai',
      followersCount: 120,
      connectionsCount: 45,
      languages: ['Hindi', 'English'],
      interests: ['Culture', 'Food', 'Photography'],
      travelStyle: 'Group',
    ),
    MockUser(
      id: 'u3',
      username: 'arjun',
      fullName: 'Arjun Nair',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      location: 'Kochi',
      followersCount: 89,
      connectionsCount: 32,
      languages: ['Malayalam', 'English'],
      interests: ['Trekking', 'Adventure', 'Camping'],
      travelStyle: 'Solo',
    ),
    MockUser(
      id: 'u4',
      username: 'sneha',
      fullName: 'Sneha Patel',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      location: 'Ahmedabad',
      followersCount: 204,
      connectionsCount: 78,
      languages: ['Gujarati', 'Hindi', 'English'],
      interests: ['Luxury', 'Culture', 'Food'],
      travelStyle: 'Couple',
    ),
  ];

  static final List<MockPackage> packages = [
    MockPackage(
      id: 'p1',
      title: 'Himalaya Package',
      location: 'Himachal Pradesh',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      price: 5000,
      rating: 4.8,
      reviewCount: 124,
      durationDays: 5,
      category: 'Adventure',
      highlights: [
        'Trek through scenic Himalayan trails',
        'Camping under the stars',
        'Visit ancient temples and monasteries',
        'Local cultural experiences',
      ],
      included: [
        'Hotel / Camping – Homestay',
        'Breakfast – Lunch – All Meals – Dinner',
        'Cultural Shows – Bonfire',
        'Cricket / Indoor Games',
        'Trekking – Paragliding – Zip-line',
      ],
      thingsToCarry: [
        'Jacket',
        'Water bottle',
        'Sunscreen',
        'Comfortable shoes',
        'Camera',
      ],
      itinerary: [
        MockDayItinerary(
          day: 1,
          title: 'Arrival & Settle In',
          activities: ['Reach hotel', 'Local sightseeing', 'Bonfire night'],
        ),
        MockDayItinerary(
          day: 2,
          title: 'Mountain Trek',
          activities: ['Morning trek', 'Lunch at camp', 'Photography session'],
        ),
        MockDayItinerary(
          day: 3,
          title: 'Adventure Activities',
          activities: [
            'Paragliding',
            'Zip-line',
            'Cultural show evening',
          ],
        ),
        MockDayItinerary(
          day: 4,
          title: 'Temple & Culture',
          activities: [
            'Visit ancient temples',
            'Local market',
            'Farewell dinner',
          ],
        ),
        MockDayItinerary(
          day: 5,
          title: 'Departure',
          activities: ['Breakfast', 'Check-out', 'Departure'],
        ),
      ],
    ),
    MockPackage(
      id: 'p2',
      title: 'Munnar Camping',
      location: 'Munnar, Kerala',
      imageUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
      price: 3500,
      rating: 4.6,
      reviewCount: 87,
      durationDays: 3,
      category: 'Camping',
      highlights: [
        'Tea plantation walks',
        'Jungle camping experience',
        'Wildlife spotting',
        'Waterfall trek',
      ],
      included: [
        'Camping – Tent stay',
        'All Meals',
        'Bonfire',
        'Nature walks',
      ],
      thingsToCarry: [
        'Jacket',
        'Insect repellent',
        'Trekking shoes',
        'Torch',
      ],
      itinerary: [
        MockDayItinerary(
          day: 1,
          title: 'Arrival & Camp Setup',
          activities: ['Check-in', 'Tea plantation walk', 'Bonfire'],
        ),
        MockDayItinerary(
          day: 2,
          title: 'Trek & Wildlife',
          activities: ['Jungle trek', 'Wildlife spotting', 'Waterfall visit'],
        ),
        MockDayItinerary(
          day: 3,
          title: 'Departure',
          activities: ['Breakfast', 'Check-out'],
        ),
      ],
    ),
    MockPackage(
      id: 'p3',
      title: 'Beachside Goa',
      location: 'Goa',
      imageUrl:
          'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800',
      price: 4200,
      rating: 4.5,
      reviewCount: 210,
      durationDays: 4,
      category: 'Beach',
      highlights: [
        'Beach camping',
        'Water sports',
        'Sunset cruise',
        'Night market',
      ],
      included: [
        'Beach resort stay',
        'Breakfast & Dinner',
        'Water sports package',
        'Sunset cruise',
      ],
      thingsToCarry: [
        'Swimwear',
        'Sunscreen',
        'Sunglasses',
        'Light clothes',
      ],
      itinerary: [
        MockDayItinerary(
          day: 1,
          title: 'Arrival',
          activities: ['Check-in', 'Beach walk', 'Dinner at shack'],
        ),
        MockDayItinerary(
          day: 2,
          title: 'Water Sports',
          activities: ['Jet skiing', 'Parasailing', 'Beach volleyball'],
        ),
        MockDayItinerary(
          day: 3,
          title: 'Cruise & Culture',
          activities: ['Old Goa churches', 'Sunset cruise', 'Night market'],
        ),
        MockDayItinerary(
          day: 4,
          title: 'Departure',
          activities: ['Breakfast', 'Check-out'],
        ),
      ],
    ),
    MockPackage(
      id: 'p4',
      title: 'Rajasthan Royal Tour',
      location: 'Jaipur, Rajasthan',
      imageUrl:
          'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800',
      price: 6500,
      rating: 4.9,
      reviewCount: 156,
      durationDays: 6,
      category: 'Culture',
      highlights: [
        'Amber Fort heritage walk',
        'Desert safari',
        'Traditional folk dance',
        'Camel ride',
      ],
      included: [
        'Heritage hotel stay',
        'All Meals',
        'Desert safari',
        'Camel ride',
        'Cultural shows',
      ],
      thingsToCarry: [
        'Light cotton clothes',
        'Scarf',
        'Sunscreen',
        'Comfortable shoes',
      ],
      itinerary: [
        MockDayItinerary(
          day: 1,
          title: 'Jaipur Arrival',
          activities: ['Check-in', 'City palace visit', 'Welcome dinner'],
        ),
        MockDayItinerary(
          day: 2,
          title: 'Forts & Palaces',
          activities: ['Amber Fort', 'Hawa Mahal', 'Local bazaar'],
        ),
        MockDayItinerary(
          day: 3,
          title: 'Jodhpur',
          activities: [
            'Mehrangarh Fort',
            'Blue city walk',
            'Folk dance evening',
          ],
        ),
        MockDayItinerary(
          day: 4,
          title: 'Jaisalmer',
          activities: ['Jaisalmer Fort', 'Desert safari', 'Camel ride'],
        ),
        MockDayItinerary(
          day: 5,
          title: 'Desert Camp',
          activities: ['Sunrise dunes', 'Cultural show', 'Bonfire night'],
        ),
        MockDayItinerary(
          day: 6,
          title: 'Departure',
          activities: ['Breakfast', 'Shopping', 'Departure'],
        ),
      ],
    ),
  ];

  static final List<MockChat> chats = [
    MockChat(
      id: 'c1',
      participant: suggestedUsers[0],
      lastMessage: MockMessage(
        id: 'm1',
        senderId: 'u2',
        text: 'Hey, how\'s your dog doing? 🐕',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      unreadCount: 2,
    ),
    MockChat(
      id: 'c2',
      participant: suggestedUsers[1],
      lastMessage: MockMessage(
        id: 'm2',
        senderId: 'u1',
        text: 'reply',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
      ),
      unreadCount: 0,
    ),
    MockChat(
      id: 'c3',
      participant: suggestedUsers[2],
      lastMessage: MockMessage(
        id: 'm3',
        senderId: 'u4',
        text: 'Are you joining the Himalaya trip?',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      unreadCount: 1,
    ),
  ];

  static final List<MockMessage> chatMessages = [
    MockMessage(
      id: 'msg1',
      senderId: 'u2',
      text: 'Hey, how\'s your dog doing? 🐕',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    MockMessage(
      id: 'msg2',
      senderId: 'u1',
      text: 'reply',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      isRead: true,
    ),
    MockMessage(
      id: 'msg3',
      senderId: 'u2',
      text: 'Hey, there\'s your day going? 😊',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
  ];

  static final List<String> trendingVibes = [
    'Beachside Camping',
    'Solo Trekking',
    'Road Trips 2024',
    'Budget Stays',
  ];

  static final List<Map<String, String>> popularEscapes = [
    {
      'name': 'Manali',
      'image':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
    },
    {
      'name': 'Goa',
      'image':
          'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=400',
    },
    {
      'name': 'Leh',
      'image':
          'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?w=400',
    },
    {
      'name': 'Coorg',
      'image':
          'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=400',
    },
    {
      'name': 'Udaipur',
      'image':
          'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=400',
    },
    {
      'name': 'Andaman',
      'image':
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400',
    },
  ];
}
