create database librarydb;
use librarydb;

create table reader (
    reader_id int primary key auto_increment,
    reader_name varchar(100) not null,
    phone varchar(15) unique,
    register_date date default (current_date)
);

create table book (
    book_id int primary key,
    book_title varchar(150) not null,
    author varchar(100),
    publish_year int check (publish_year >= 1900)
);

create table borrow (
    reader_id int,
    book_id int,
    borrow_date date default (current_date),
    return_date date,
    primary key (reader_id, book_id, borrow_date),
    foreign key (reader_id) references reader(reader_id),
    foreign key (book_id) references book(book_id)
);


alter table reader add column email varchar(100) unique;

alter table book modify column author varchar(150);

alter table borrow add constraint chk_return_date  check (return_date is null or return_date >= borrow_date);

insert into reader (reader_id, reader_name, phone, email, register_date) values
(1, 'nguyễn văn an', '0901234567', 'an.nguyen@gmail.com', '2024-09-01'),
(2, 'trần thị bình', '0912345678', 'binh.tran@gmail.com', '2024-09-05'),
(3, 'lê minh châu', '0923456789', 'chau.le@gmail.com', '2024-09-10');

insert into book (book_id, book_title, author, publish_year) values
(101, 'lập trình c căn bản', 'nguyễn văn a', 2018),
(102, 'cơ sở dữ liệu', 'trần thị b', 2020),
(103, 'lập trình java', 'lê minh c', 2019),
(104, 'hệ quản trị mysql', 'phạm văn d', 2021);

insert into borrow (reader_id, book_id, borrow_date, return_date) values
(1, 101, '2024-09-15', null),
(1, 102, '2024-09-15', '2024-09-25'),
(2, 103, '2024-09-18', null);

update borrow set return_date = '2024-10-01' where reader_id = 1;

update book set publish_year = 2023 where publish_year >= 2021;

delete from borrow where borrow_date < '2024-09-18';

select * from reader;

select * from book;

select * from borrow;