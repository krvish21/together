const PRESEEDED_QUESTIONS = [
  // Romantic
  {
    category: 'Romantic',
    text: 'What was the exact moment you realized you had feelings for me?'
  },
  {
    category: 'Romantic',
    text: 'What is a small, everyday gesture of mine that never fails to make you smile?'
  },
  {
    category: 'Romantic',
    text: 'If we could relive any single day from our relationship, which day would you pick?'
  },
  {
    category: 'Romantic',
    text: 'What is your favorite photo of us, and why does it mean so much to you?'
  },
  {
    category: 'Romantic',
    text: 'What is something you find incredibly attractive about me that isn\'t physical?'
  },
  {
    category: 'Romantic',
    text: 'How do you feel most loved by me (words, touch, surprises, quality time)?'
  },

  // Deep
  {
    category: 'Deep',
    text: 'How has being with me changed or shaped the way you look at the world?'
  },
  {
    category: 'Deep',
    text: 'What is a personal fear or insecurity you\'ve felt safe sharing with me?'
  },
  {
    category: 'Deep',
    text: 'Where do you hope we are in our lives and relationship 5 years from now?'
  },
  {
    category: 'Deep',
    text: 'What is a life goal that you\'re excited for us to achieve together?'
  },
  {
    category: 'Deep',
    text: 'What does unconditional love look like to you in everyday life?'
  },

  // Funny
  {
    category: 'Funny',
    text: 'If our relationship were a comedy TV series, what would the title be?'
  },
  {
    category: 'Funny',
    text: 'What is my weirdest habit that you secretly find hilarious or endearing?'
  },
  {
    category: 'Funny',
    text: 'In a zombie apocalypse, which one of us survives longer and why?'
  },
  {
    category: 'Funny',
    text: 'What is the most ridiculous argument we\'ve ever laughed about afterwards?'
  },
  {
    category: 'Funny',
    text: 'If you had to describe my cooking skills using only movie titles, what would it be?'
  },

  // Hypothetical
  {
    category: 'Hypothetical',
    text: 'If we were gifted a free vacation anywhere in the world for 2 weeks tomorrow, where are we heading?'
  },
  {
    category: 'Hypothetical',
    text: 'If we won a million dollars, what would our very first purchase together be?'
  },
  {
    category: 'Hypothetical',
    text: 'If time froze for 24 hours and only the two of us could move, what would we do?'
  },
  {
    category: 'Hypothetical',
    text: 'If we could open a quirky small business together, what would we sell?'
  }
];

const PRESEEDED_GAMES = [
  {
    game_type: 'would_you_rather',
    title: 'Cozy Mountains vs Tropical Beach',
    game_data: {
      question: 'Would you rather spend a 7-day vacation in...',
      optionA: 'A cozy snowy cabin with hot cocoa and a fireplace',
      optionB: 'An oceanfront beach bungalow with warm waves and sunset cocktails',
      p1Choice: null,
      p2Choice: null,
      p1GuessP2: null,
      p2GuessP1: null,
      round: 1
    }
  },
  {
    game_type: 'would_you_rather',
    title: 'Infinite Breakfast vs Midnight Road Trips',
    game_data: {
      question: 'Would you rather have for the rest of our lives...',
      optionA: 'Gourmet breakfast in bed every Sunday morning',
      optionB: 'Spontaneous midnight drives under starry skies with favorite snacks',
      p1Choice: null,
      p2Choice: null,
      p1GuessP2: null,
      p2GuessP1: null,
      round: 1
    }
  },
  {
    game_type: 'this_or_that',
    title: 'Daily Habits & Vibe Check',
    game_data: {
      items: [
        { item: 'Coffee or Tea?', p1: null, p2: null },
        { item: 'Staying in watching movies or Dressing up going out?', p1: null, p2: null },
        { item: 'Cook dinner together or Order delicious takeout?', p1: null, p2: null },
        { item: 'Morning person or Night owl?', p1: null, p2: null }
      ]
    }
  },
  {
    game_type: 'guess_my_answer',
    title: 'Secret Comfort Food',
    game_data: {
      prompt: 'What is my ultimate go-to comfort food when I have had a exhausting day?',
      author: 'partner1',
      actualAnswer: '',
      partnerGuess: '',
      revealed: false,
      score: 0
    }
  },
  {
    game_type: 'truth_or_dare',
    title: 'Couple\'s Truth or Dare',
    game_data: {
      cards: [
        { type: 'truth', text: 'What is one thing I wore that you thought looked breathtaking on me?' },
        { type: 'dare', text: 'Send a 5-second selfie video singing the chorus of our song!' },
        { type: 'truth', text: 'What is your secret favorite nickname for me?' },
        { type: 'dare', text: 'Give me a 3-minute gentle shoulder massage or redeem one virtual massage coupon right now!' }
      ],
      currentCardIndex: 0,
      completedCards: []
    }
  },
  {
    game_type: 'who_knows_better',
    title: 'Couple Trivia Showdown',
    game_data: {
      questions: [
        { q: 'Who usually falls asleep faster at night?', p1: null, p2: null },
        { q: 'Who is more likely to lose their keys or phone?', p1: null, p2: null },
        { q: 'Who spends more time picking what to watch or eat?', p1: null, p2: null },
        { q: 'Who was the first one to say "I love you"?', p1: null, p2: null }
      ],
      p1Score: 0,
      p2Score: 0
    }
  }
];

module.exports = {
  PRESEEDED_QUESTIONS,
  PRESEEDED_GAMES
};
