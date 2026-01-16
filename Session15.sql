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


-- Procedure gửi lời mời kết bạn
DELIMITER //
CREATE PROCEDURE SendFriendRequest(IN p_user_id INT, IN p_friend_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Lỗi khi gửi lời mời! Đã rollback.' AS message;
    END;

    START TRANSACTION;

    IF EXISTS (
        SELECT 1 FROM friends
        WHERE (user_id = p_user_id AND friend_id = p_friend_id)
           OR (user_id = p_friend_id AND friend_id = p_user_id)
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quan hệ đã tồn tại';
    END IF;

    INSERT INTO friends (user_id, friend_id, status)
    VALUES (p_user_id, p_friend_id, 'pending');

    COMMIT;
    SELECT 'Gửi lời mời thành công!' AS message;
END //
DELIMITER ;


-- Procedure cập nhật/xóa mối quan hệ 
DELIMITER //
CREATE PROCEDURE ManageFriendship(
    IN p_user_id INT,
    IN p_friend_id INT,
    IN p_action VARCHAR(20)
)
BEGIN
    DECLARE current_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Lỗi đã rollback!' AS message;
    END;

    START TRANSACTION;

    SELECT status INTO current_status
    FROM friends
    WHERE (user_id = p_user_id AND friend_id = p_friend_id)
       OR (user_id = p_friend_id AND friend_id = p_user_id)
    LIMIT 1;

    IF current_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại mối quan hệ!';
    END IF;

    IF p_action = 'accept' THEN
        IF current_status = 'pending' THEN
            UPDATE friends
            SET status = 'accepted'
            WHERE (user_id = p_user_id AND friend_id = p_friend_id)
               OR (user_id = p_friend_id AND friend_id = p_user_id);
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chỉ accept khi pending';
        END IF;
    ELSEIF p_action = 'delete' THEN
        DELETE FROM friends
        WHERE (user_id = p_user_id AND friend_id = p_friend_id)
           OR (user_id = p_friend_id AND friend_id = p_user_id);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chỉ dùng accept hoặc delete';
    END IF;

    COMMIT;
    SELECT CONCAT('Thao tác ', p_action, ' thành công!') AS message;
END //
DELIMITER ;

-- Giử lời mời
CALL SendFriendRequest(1, 4);
-- Chấp nhận bạn bè
CALL ManageFriendship(4, 1, 'accept'); 
-- Xóa bạn bè
CALL ManageFriendship(1, 4, 'delete'); 
-- Test lỗi 
CALL ManageFriendship(1, 999, 'accept');
