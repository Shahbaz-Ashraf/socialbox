const kPredefinedCategories = <Map<String, String>>[
  {
    'id': 'cat_engagement',
    'name': 'Engagement',
    'icon': '👋',
    'color': '#4CAF50',
  },
  {
    'id': 'cat_congrats',
    'name': 'Congratulations',
    'icon': '🎉',
    'color': '#FF9800',
  },
  {
    'id': 'cat_professional',
    'name': 'Professional',
    'icon': '💼',
    'color': '#2196F3',
  },
  {
    'id': 'cat_promotional',
    'name': 'Promotional',
    'icon': '📢',
    'color': '#E91E63',
  },
  {
    'id': 'cat_appreciation',
    'name': 'Appreciation',
    'icon': '🙏',
    'color': '#9C27B0',
  },
  {
    'id': 'cat_questions',
    'name': 'Questions',
    'icon': '❓',
    'color': '#00BCD4',
  },
  {
    'id': 'cat_support',
    'name': 'Support',
    'icon': '💪',
    'color': '#FF5722',
  },
  {
    'id': 'cat_general',
    'name': 'General',
    'icon': '💬',
    'color': '#607D8B',
  },
];

const kPredefinedComments = <String, List<String>>{
  'cat_engagement': [
    'Great content as always! Keeping me coming back for more. 🙌',
    'Really valuable insights here, thank you for sharing!',
    'This is exactly what I needed to read today. Bookmarking this!',
    'Love the way you explained this. So clear and practical!',
    'This really made me think! What inspired this post?',
  ],
  'cat_congrats': [
    'Congratulations on this amazing achievement! Well deserved! 🎉',
    "So excited to see this announcement! You've worked so hard for this!",
    'Huge congratulations! This is just the beginning of something great!',
    'This is truly inspiring! Congratulations on your success! 🏆',
    'What a milestone! Congratulations and wishing you even greater success!',
  ],
  'cat_professional': [
    'Excellent perspective on this. Very directly applicable to our work.',
    'From my experience in this field, this approach delivers the best results.',
    'Great analysis. The key takeaway for professionals here is spot on.',
    'Thank you for sharing this insight. Adding it to our team playbook!',
    'This is exactly the kind of thought leadership our industry needs.',
  ],
  'cat_promotional': [
    "We've been building something that solves exactly this! Feel free to DM.",
    'Tag someone in your network who needs to see this! 👇',
    'Share this with your connections if you found it valuable! 🔁',
    'This is why we built our product. Would love your feedback!',
    'If this resonates, you\'d love what we\'re working on. Check the link!',
  ],
  'cat_appreciation': [
    'Thank you so much for sharing this! Really helpful and timely.',
    'Your content always adds value to my day. Much appreciated!',
    'I really appreciate the effort you put into creating this. Thank you!',
    'This community is amazing because of people like you. Thank you!',
    'Grateful for this resource. Sharing it with my team right away!',
  ],
  'cat_questions': [
    'This is fascinating! How did you arrive at this conclusion?',
    'What would you recommend for someone just starting out here?',
    'Have you seen any real-world success stories with this approach?',
    'What was the biggest challenge you faced while implementing this?',
    'How does this compare to the more traditional approach?',
  ],
  'cat_support': [
    "You've got this! Keep pushing forward! 💪",
    "We're all rooting for you! This is going to be incredible!",
    'Believe in yourself — the hard work always pays off!',
    'Tackling this head-on is the right move. Respect!',
    'Remember why you started. You\'re doing absolutely great!',
  ],
  'cat_general': [
    'Great post! Thanks for sharing.',
    'Very insightful. Saved for future reference!',
    'Sharing this — more people need to see it.',
    "Couldn't agree more with this perspective!",
    'This just made it to my must-read list!',
  ],
};

// Bonus: AI-suggested starter templates for posts
const kPostTemplates = <String, List<String>>{
  'announcement': [
    '🚀 Exciting news! We just launched [PRODUCT/FEATURE]. Here\'s what you need to know:',
    'After months of hard work, we\'re thrilled to announce [ANNOUNCEMENT]!',
    'Big day for our team! Today we\'re sharing [NEWS] with the world.',
  ],
  'tip': [
    '💡 Here\'s a tip that transformed how I [ACTION]: [TIP]',
    'Quick lesson learned: [LESSON]. Hope this saves you time!',
    'Pro tip: [TIP]. Try it and let me know how it goes!',
  ],
  'question': [
    'Curious — what\'s your take on [TOPIC]?',
    'Question for my network: how do you handle [CHALLENGE]?',
    'What\'s one tool you can\'t live without for [TASK]?',
  ],
  'inspiration': [
    'Reminder: [INSPIRATIONAL_QUOTE]',
    'The best investment you can make is in yourself. 💪',
    'Progress over perfection. Always.',
  ],
  'milestone': [
    '🎉 We just hit [NUMBER] [METRIC]! Thank you to everyone who supported us.',
    'Milestone unlocked: [MILESTONE]. Grateful for this journey.',
    'Today marks [DAYS/MONTHS/YEARS] of [ACHIEVEMENT]. Onwards and upwards!',
  ],
};
