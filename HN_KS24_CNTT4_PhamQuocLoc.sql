create database session12;
use session12;

create table users(
  user_id int primary key auto_increment,
  username varchar(50) unique not null,
  password varchar(255) not null,
  email varchar(100) unique not null,
  created_at datetime default current_timestamp
);

create table posts(
  post_id int primary key auto_increment,
  user_id int,
  content text not null,
  created_at datetime default current_timestamp,
  foreign key (user_id) references users(user_id)
);
-- ===== 1) USERS (10 rows) =====
insert into users (username, password, email) values
('user01','pass01','user01@gmail.com'),
('user02','pass02','user02@gmail.com'),
('user03','pass03','user03@gmail.com'),
('user04','pass04','user04@gmail.com'),
('user05','pass05','user05@gmail.com'),
('user06','pass06','user06@gmail.com'),
('user07','pass07','user07@gmail.com'),
('user08','pass08','user08@gmail.com'),
('user09','pass09','user09@gmail.com'),
('user10','pass10','user10@gmail.com');

-- ===== 2) POSTS (10 rows) =====
insert into posts (user_id, content) values
(1, 'Post 1: Hello world!'),
(2, 'Post 2: Today is a good day.'),
(3, 'Post 3: Learning MySQL.'),
(4, 'Post 4: Mini project social network.'),
(5, 'Post 5: I love databases.'),
(6, 'Post 6: Practice makes perfect.'),
(7, 'Post 7: Views and indexes are useful.'),
(8, 'Post 8: Stored procedures are cool.'),
(9, 'Post 9: Working on comments & likes.'),
(10,'Post 10: Done posting!');

-- ===== 3) COMMENTS (10 rows) =====
insert into comments (post_id, user_id, content) values
(1, 2, 'Nice post!'),
(1, 3, 'Hello!'),
(2, 1, 'Agree with you.'),
(3, 4, 'Good luck!'),
(4, 5, 'Interesting project.'),
(5, 6, 'Database is fun.'),
(6, 7, 'Keep going!'),
(7, 8, 'Great info.'),
(8, 9, 'Procedures help a lot.'),
(10,1, 'Congrats!');

-- ===== 4) FRIENDS (10 rows) =====
insert into friends (user_id, friend_id, status) values
(1, 2, 'accepted'),
(1, 3, 'pending'),
(2, 3, 'accepted'),
(2, 4, 'pending'),
(3, 5, 'accepted'),
(4, 5, 'pending'),
(6, 7, 'accepted'),
(7, 8, 'pending'),
(8, 9, 'accepted'),
(9,10, 'pending');

-- ===== 5) LIKES (10 rows) =====
insert into likes (user_id, post_id) values
(2, 1),
(3, 1),
(1, 2),
(4, 3),
(5, 4),
(6, 5),
(7, 6),
(8, 7),
(9, 8),
(10,9);

create table comments(
  comment_id int primary key auto_increment,
  post_id int,
  user_id int,
  content text not null,
  created_at datetime default current_timestamp,
  foreign key (post_id) references posts(post_id),
  foreign key (user_id) references users(user_id)
);

create table friends(
  user_id int,
  friend_id int,
  status varchar(20),
  check (status in ('pending','accepted')),
  foreign key (user_id) references users(user_id),
  foreign key (friend_id) references users(user_id)
);

create table likes(
  user_id int,
  post_id int,
  foreign key (user_id) references users(user_id),
  foreign key (post_id) references posts(post_id)
);

-- 5.1) Tạo VIEW vw_recent_posts: lấy bài viết trong 7 ngày gần nhất
CREATE VIEW vw_recent_posts AS
SELECT 
    p.post_id,
    p.user_id,
    u.username,
    p.content,
    p.created_at,
    -- Đếm số like (nếu không có thì 0)
    COALESCE((
        SELECT COUNT(*) 
        FROM likes l 
        WHERE l.post_id = p.post_id
    ), 0) AS like_count,
    -- Đếm số comment (nếu không có thì 0)
    COALESCE((
        SELECT COUNT(*) 
        FROM comments c 
        WHERE c.post_id = p.post_id
    ), 0) AS comment_count
FROM 
    posts p
    INNER JOIN users u ON p.user_id = u.user_id
WHERE 
    p.created_at >= NOW() - INTERVAL 7 DAY
ORDER BY 
    p.created_at DESC;


-- 5.2) Một số truy vấn mẫu sử dụng View (News Feed)

-- News Feed cơ bản (tất cả bài viết 7 ngày gần nhất)
SELECT * FROM vw_recent_posts
LIMIT 20;


-- News Feed với thông tin chi tiết hơn
SELECT 
    post_id,
    username,
    content,
    created_at,
    like_count,
    comment_count,
    TIME_FORMAT(TIMEDIFF(NOW(), created_at), '%H:%i:%s') AS time_ago
FROM vw_recent_posts
ORDER BY created_at DESC
LIMIT 15;


-- News Feed chỉ lấy của bạn bè (cách 1 - đơn giản)
SELECT 
    p.*
FROM vw_recent_posts p
WHERE p.user_id IN (
    SELECT friend_id 
    FROM friends 
    WHERE user_id = 1          -- thay bằng user đang đăng nhập
    AND status = 'accepted'
)
   OR p.user_id = 1            -- bao gồm bài của chính mình
ORDER BY p.created_at DESC;


-- 7.1) Tạo Stored Procedure đếm số bài viết của một user
DELIMITER //

CREATE PROCEDURE sp_count_posts(
    IN  p_user_id INT,
    OUT p_total_posts INT,
    OUT p_total_likes_received INT,
    OUT p_total_comments_received INT,
    OUT p_total_comments_made INT,
    OUT p_total_friends INT
)
BEGIN
    -- 1. Tổng số bài viết của user
    SELECT COUNT(*) INTO p_total_posts
    FROM posts
    WHERE user_id = p_user_id;

    -- 2. Tổng số like mà các bài của user nhận được
    SELECT COUNT(*) INTO p_total_likes_received
    FROM likes l
    INNER JOIN posts p ON l.post_id = p.post_id
    WHERE p.user_id = p_user_id;

    -- 3. Tổng số comment mà các bài của user nhận được
    SELECT COUNT(*) INTO p_total_comments_received
    FROM comments c
    INNER JOIN posts p ON c.post_id = p.post_id
    WHERE p.user_id = p_user_id;

    -- 4. Tổng số comment mà user đã viết
    SELECT COUNT(*) INTO p_total_comments_made
    FROM comments
    WHERE user_id = p_user_id;

    -- 5. Tổng số bạn bè (chỉ tính mối quan hệ đã accepted, tránh đếm 2 chiều)
    SELECT COUNT(*) INTO p_total_friends
    FROM friends
    WHERE (user_id = p_user_id OR friend_id = p_user_id)
      AND status = 'accepted';

END //

DELIMITER ;


-- 7.2) Cách gọi và xem kết quả

-- Cách 1: Dùng biến
SET @user = 1;                -- thay bằng user_id bạn muốn xem
SET @total_posts = 0;
SET @total_likes = 0;
SET @total_comments_received = 0;
SET @total_comments_made = 0;
SET @total_friends = 0;

CALL sp_count_posts(@user, 
                   @total_posts, 
                   @total_likes, 
                   @total_comments_received,
                   @total_comments_made,
                   @total_friends);

SELECT 
    @user AS user_id,
    @total_posts AS total_posts,
    @total_likes AS total_likes_received,
    @total_comments_received AS comments_on_my_posts,
    @total_comments_made AS comments_i_made,
    @total_friends AS total_friends;


-- Cách 2: Gọi nhanh cho một user cụ thể (dễ test)
CALL sp_count_posts(1, @p, @l, @cr, @cm, @f);
SELECT @p AS posts, @l AS likes_received, @cr AS comments_received, @cm AS comments_made, @f AS friends;
