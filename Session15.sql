create database session15;
use session15;
CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE posts (
  post_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);
CREATE TABLE comments (
  comment_id INT PRIMARY KEY AUTO_INCREMENT,
  post_id INT,
  user_id INT,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id)
    REFERENCES posts(post_id)
    ON DELETE CASCADE,
  FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);
CREATE TABLE likes (
  user_id INT,
  post_id INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, post_id),
  FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE,
  FOREIGN KEY (post_id)
    REFERENCES posts(post_id)
    ON DELETE CASCADE
);
CREATE TABLE friends (
  user_id INT,
  friend_id INT,
  status VARCHAR(20) DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, friend_id),
  CHECK (status IN ('pending', 'accepted')),
  FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE,
  FOREIGN KEY (friend_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);

INSERT INTO users (username, password, email) VALUES
('alice', 'pass123', 'alice@gmail.com'),
('bob', 'pass123', 'bob@gmail.com'),
('charlie', 'pass123', 'charlie@gmail.com'),
('david', 'pass123', 'david@gmail.com'),
('emma', 'pass123', 'emma@gmail.com'),
('frank', 'pass123', 'frank@gmail.com'),
('grace', 'pass123', 'grace@gmail.com'),
('henry', 'pass123', 'henry@gmail.com');

INSERT INTO posts (user_id, content) VALUES
(1, 'Hello world!'),
(2, 'My first post'),
(3, 'Learning MySQL'),
(4, 'Good morning everyone'),
(5, 'I love programming'),
(6, 'Database design is fun'),
(7, 'SQL is powerful'),
(8, 'Nice to meet you all');

INSERT INTO comments (post_id, user_id, content) VALUES
(1, 2, 'Nice post!'),
(1, 3, 'Welcome!'),
(2, 1, 'Good luck'),
(3, 4, 'Keep learning'),
(4, 5, 'Good morning'),
(5, 6, 'Programming is awesome'),
(6, 7, 'I agree'),
(7, 8, 'Well said');

INSERT INTO likes (user_id, post_id) VALUES
(1, 2),
(2, 1),
(3, 1),
(4, 3),
(5, 4),
(6, 5),
(7, 6),
(8, 7);

INSERT INTO friends (user_id, friend_id, status) VALUES
(1, 2, 'accepted'),
(1, 3, 'pending'),
(2, 3, 'accepted'),
(2, 4, 'pending'),
(3, 5, 'accepted'),
(4, 6, 'pending'),
(5, 7, 'accepted'),
(6, 8, 'pending');

SELECT * FROM users;
SELECT * FROM posts;
SELECT * FROM comments;
SELECT * FROM likes;
SELECT * FROM friends;



