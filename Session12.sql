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
 

-- bài 1
create table users (
    user_id int primary key auto_increment,
    username varchar(50) unique not null,
    password varchar(255) not null,
    email varchar(100) unique not null,
    created_at datetime default current_timestamp
);

insert into users (username, password, email) values
('user01', 'pass01', 'user01@gmail.com'),
('user02', 'pass02', 'user02@gmail.com');

select * from users;


-- bài 2
create view vw_public_users as
select user_id, username, created_at
from users;

select * from vw_public_users;

-- so sánh
select user_id, username, created_at from users;  -- trực tiếp từ bảng


-- bài 3
create index idx_username on users(username);

-- có index
select * from users where username = 'user01';

-- không index (lý thuyết): phải full table scan → chậm hơn khi bảng lớn


-- bài 4
delimiter //
create procedure sp_create_post(
    in p_user_id int,
    in p_content text
)
begin
    if exists (select 1 from users where user_id = p_user_id) then
        insert into posts (user_id, content)
        values (p_user_id, p_content);
    else
        signal sqlstate '45000' set message_text = 'user khong ton tai';
    end if;
end //
delimiter ;

call sp_create_post(1, 'bai viet dau tien');


-- bài 5
create view vw_recent_posts as
select 
    p.post_id,
    u.username,
    p.content,
    p.created_at
from posts p
join users u on p.user_id = u.user_id
where p.created_at >= now() - interval 7 day
order by p.created_at desc;

select * from vw_recent_posts;


-- bài 6
create index idx_posts_user_id on posts(user_id);
create index idx_posts_user_created on posts(user_id, created_at desc);

-- truy vấn
select * from posts 
where user_id = 1 
order by created_at desc;


-- bài 7
delimiter //
create procedure sp_count_posts(
    in p_user_id int,
    out p_total int
)
begin
    select count(*) into p_total
    from posts
    where user_id = p_user_id;
end //
delimiter ;

set @total = 0;
call sp_count_posts(1, @total);
select @total as total_posts;


-- bài 8
-- giả sử có cột is_active tinyint default 1 trong users (nếu chưa có thì thêm trước)
-- alter table users add column is_active tinyint default 1;

create view vw_active_users as
select user_id, username, email, created_at
from users
where is_active = 1
with check option;

-- test
insert into vw_active_users (username, password, email, is_active) 
values ('testuser', '123', 'test@gmail.com', 0);  -- sẽ bị từ chối


-- bài 9
delimiter //
create procedure sp_add_friend(
    in p_user_id int,
    in p_friend_id int
)
begin
    if p_user_id = p_friend_id then
        signal sqlstate '45000' set message_text = 'khong the ket ban voi chinh minh';
    elseif not exists (select 1 from users where user_id = p_user_id) then
        signal sqlstate '45000' set message_text = 'user khong ton tai';
    elseif not exists (select 1 from users where user_id = p_friend_id) then
        signal sqlstate '45000' set message_text = 'friend khong ton tai';
    else
        insert ignore into friends (user_id, friend_id, status)
        values (p_user_id, p_friend_id, 'pending');
    end if;
end //
delimiter ;

call sp_add_friend(1, 2);


-- bài 10
delimiter //
create procedure sp_suggest_friends(
    in p_user_id int,
    inout p_limit int
)
begin
    declare done int default 0;
    declare suggested_id int;
    declare cur cursor for
        select u.user_id
        from users u
        where u.user_id != p_user_id
        and u.user_id not in (
            select friend_id from friends where user_id = p_user_id
            union
            select user_id from friends where friend_id = p_user_id
        )
        limit p_limit;
    declare continue handler for not found set done = 1;

    drop temporary table if exists temp_suggestions;
    create temporary table temp_suggestions (suggested_user_id int);

    open cur;

    read_loop: loop
        fetch cur into suggested_id;
        if done then
            leave read_loop;
        end if;
        insert into temp_suggestions values (suggested_id);
    end loop;

    close cur;

    select * from temp_suggestions;
    set p_limit = (select count(*) from temp_suggestions);
end //
delimiter ;


-- bài 11
create view vw_top_posts as
select 
    l.post_id,
    count(*) as like_count
from likes l
group by l.post_id
order by like_count desc
limit 5;

create index idx_likes_post_id on likes(post_id);


-- bài 12
delimiter //
create procedure sp_add_comment(
    in p_user_id int,
    in p_post_id int,
    in p_content text
)
begin
    declare user_exists int;
    declare post_exists int;

    select count(*) into user_exists from users where user_id = p_user_id;
    select count(*) into post_exists from posts where post_id = p_post_id;

    if user_exists = 0 then
        signal sqlstate '45000' set message_text = 'user khong ton tai';
    elseif post_exists = 0 then
        signal sqlstate '45000' set message_text = 'bai viet khong ton tai';
    else
        insert into comments (post_id, user_id, content)
        values (p_post_id, p_user_id, p_content);
    end if;
end //
delimiter ;

create view vw_post_comments as
select 
    c.content,
    u.username,
    c.created_at
from comments c
join users u on c.user_id = u.user_id
order by c.created_at desc;


-- bài 13
delimiter //
create procedure sp_like_post(
    in p_user_id int,
    in p_post_id int
)
begin
    if not exists (
        select 1 from likes 
        where user_id = p_user_id and post_id = p_post_id
    ) then
        insert into likes (user_id, post_id)
        values (p_user_id, p_post_id);
    end if;
end //
delimiter ;

create view vw_post_likes as
select 
    post_id,
    count(*) as like_count
from likes
group by post_id;


-- bài 14
delimiter //
create procedure sp_search_social(
    in p_option int,
    in p_keyword varchar(100)
)
begin
    if p_option = 1 then
        select user_id, username, email, created_at
        from users
        where username like concat('%', p_keyword, '%');
    elseif p_option = 2 then
        select p.post_id, u.username, p.content, p.created_at
        from posts p
        join users u on p.user_id = u.user_id
        where p.content like concat('%', p_keyword, '%')
        order by p.created_at desc;
    else
        signal sqlstate '45000' set message_text = 'option khong hop le (chi 1 hoac 2)';
    end if;
end //
delimiter ;

-- gọi ví dụ
call sp_search_social(1, 'an');
call sp_search_social(2, 'database');
