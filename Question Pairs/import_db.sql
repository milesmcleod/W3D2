DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  subject_question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (subject_question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Henry', 'Chen'),
  ('Miles', 'McLeod'),
  ('Taylor', 'Swift');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Color', 'What''s your favorite color?', (SELECT id FROM users WHERE fname = 'Henry')),
  ('Favorite Band', 'What''s your favorite band?', (SELECT id FROM users WHERE fname = 'Miles')),
  ('Ice Cream', 'What''s your favorite ice cream?', (SELECT id FROM users WHERE fname = 'Miles'));
INSERT INTO
  replies (subject_question_id, parent_reply_id, user_id, body)
VALUES
  (1, NULL, 2, 'Blue'),
  (3, NULL, 1, 'Strawberry'),
  (1, 1, 2, 'Green');


INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (1, 1),
  (1, 2),
  (1, 3),
  (3, 1);

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (2, 1),
  (2, 2),
  (1, 1),
  (3, 1);
