-- Reference data: 8 topics and 32 essay prompts (4 per topic).

insert into public.topics (code, name, icon, sort_order) values
  ('math',      'Mathematics',             'calculate',   1),
  ('english',   'English',                 'menu_book',   2),
  ('french',    'French',                  'translate',   3),
  ('science',   'Science',                 'science',     4),
  ('politics',  'Politics',                'account_balance', 5),
  ('economics', 'Economics',               'trending_up', 6),
  ('finance',   'Finance',                 'savings',     7),
  ('relations', 'International Relations', 'public',      8)
on conflict (code) do update set
  name = excluded.name,
  icon = excluded.icon,
  sort_order = excluded.sort_order;

insert into public.essay_prompts (topic_code, prompt) values
  ('math',      'Explain why being good at mental arithmetic is still useful in a world full of calculators.'),
  ('math',      'Describe a time when numbers helped you make a better decision. What did you learn?'),
  ('math',      'Should every adult understand basic percentages? Give reasons and examples.'),
  ('math',      'Explain a simple mathematical idea to someone who is afraid of maths.'),
  ('english',   'Write about a word or phrase you love and explain why it is powerful.'),
  ('english',   'Is it more important to speak correctly or to speak confidently? Argue your view.'),
  ('english',   'Describe a book, article or speech that changed the way you think.'),
  ('english',   'Write a letter to your younger self about the value of reading.'),
  ('french',    'Why is learning a second language worth the effort for an adult? Give three reasons.'),
  ('french',    'Describe a place where French is spoken that you would like to visit, and why.'),
  ('french',    'What is the hardest part of learning a new language, and how would you overcome it?'),
  ('french',    'How can learning French help someone in their career in Africa or elsewhere?'),
  ('science',   'Which scientific discovery has had the biggest effect on daily life? Defend your choice.'),
  ('science',   'Should governments spend more money on space exploration or on problems at home?'),
  ('science',   'Explain how technology has changed the way people learn.'),
  ('science',   'Describe the steps you would take to test a claim you saw on social media.'),
  ('politics',  'What makes a good leader? Use examples to support your answer.'),
  ('politics',  'Explain why young people should or should not take part in elections.'),
  ('politics',  'Describe the role of a free press in a healthy society.'),
  ('politics',  'Compare two ways a country can choose its leaders. Which do you think is fairer?'),
  ('economics', 'Explain how rising prices affect ordinary families, and what they can do about it.'),
  ('economics', 'Should a country produce most of what it needs or trade for it? Argue your view.'),
  ('economics', 'Describe how a small business can create jobs and help a community grow.'),
  ('economics', 'What is one economic change that would improve life in your country? Explain why.'),
  ('finance',   'Why is saving money difficult, and what habits make it easier?'),
  ('finance',   'Should schools teach personal finance? Give reasons and examples.'),
  ('finance',   'Describe how you would plan a monthly budget for a young adult.'),
  ('finance',   'Is it better to invest early with little money, or wait until you have more? Explain.'),
  ('relations', 'Why do countries form alliances? Use at least one real example.'),
  ('relations', 'How can regional organisations such as the AU or SADC help their member states?'),
  ('relations', 'Is the United Nations still important today? Argue your view.'),
  ('relations', 'Describe how trade can build peace between countries.')
on conflict (prompt) do nothing;
