PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  PRIMARY KEY (user_id, question_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  parent_id INTEGER,

  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
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
  ('Ian','Ellison'),
  ('Marc','Schlossberg'),
  ('Someasshole', 'notnamedken'),
  ('Kevin','Durant');

INSERT INTO
  questions (title,body,author_id)
VALUES
  ('Where', 'Where the hell am I??!!!', 
  (SELECT id FROM users WHERE fname = 'Ian')
  ),
  ('Who', 'Who the where am the hell you?',
  (SELECT id FROM users WHERE fname = 'Marc')
  );

INSERT INTO
  question_follows (user_id,question_id)
VALUES
  (
  (SELECT id FROM users WHERE fname = 'Kevin'),
  (SELECT id FROM questions WHERE title = 'Where')
  ),
  (
  (SELECT id FROM users WHERE fname = 'Someasshole'),
  (SELECT id FROM questions WHERE title = 'Where')
  );

INSERT INTO
  replies (question_id,user_id,body,parent_id)
VALUES
  (
  (SELECT id FROM questions WHERE title = 'Where'),
  (SELECT id FROM users WHERE fname = 'Marc'),
  "Why is where tho bro?", NULL
  );

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (
  (SELECT id FROM users WHERE fname = 'Someasshole'),
  (SELECT id FROM questions WHERE title = 'Where')
  );
 



