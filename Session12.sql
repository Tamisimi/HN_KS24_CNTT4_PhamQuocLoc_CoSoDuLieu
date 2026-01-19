drop database studentdb;
create database studentdb;
use studentdb;

-- 1. Bảng khoa
create table department (
    deptid char(5) primary key,
    deptname varchar(50) not null
);

-- 2. Bảng sinh viên
create table student (
    studentid char(6) primary key,
    fullname varchar(50),
    gender varchar(10),
    birthdate date,
    deptid char(5),
    foreign key (deptid) references department(deptid)
);

-- 3. Bảng môn học
create table course (
    courseid char(6) primary key,
    coursename varchar(50),
    credits int
);

-- 4. Bảng đăng ký
create table enrollment (
    studentid char(6),
    courseid char(6),
    score float,
    primary key (studentid, courseid),
    foreign key (studentid) references student(studentid),
    foreign key (courseid) references course(courseid)
);

insert into department values
('it','information technology'),
('ba','business administration'),
('acc','accounting');

insert into student values
('s00001','nguyen an','male','2003-05-10','it'),
('s00002','tran binh','male','2003-06-15','it'),
('s00003','le hoa','female','2003-08-20','ba'),
('s00004','pham minh','male','2002-12-12','acc'),
('s00005','vo lan','female','2003-03-01','it'),
('s00006','do hung','male','2002-11-11','ba'),
('s00007','nguyen mai','female','2003-07-07','acc'),
('s00008','tran phuc','male','2003-09-09','it');

insert into course values
('c00001','database systems',3),
('c00002','c programming',3),
('c00003','microeconomics',2),
('c00004','financial accounting',3);

insert into enrollment values
('s00001','c00001',8.5),
('s00001','c00002',7.0),
('s00002','c00001',6.5),
('s00003','c00003',7.5),
('s00004','c00004',8.0),
('s00005','c00001',9.0),
('s00006','c00003',6.0),
('s00007','c00004',7.0),
('s00008','c00001',5.5),
('s00008','c00002',6.5);

-- Câu 1:
create view view_studentbasic as
select s.studentid, s.fullname, d.deptname
from student s join department d on s.deptid = d.deptid;

-- Câu 2:
create index regular on student(fullname);

-- Câu 3:
delimiter $$

create procedure getstudentsit()
begin 
    select s.*, d.deptname from student s 
    join department d on s.deptid = d.deptid
    where d.deptname = 'information technology';
end $$

delimiter ;

call getstudentsit();

-- Câu 4:
drop view if exists view_studentcountbydept;
create view view_studentcountbydept as
select d.deptname, count(s.studentid) as totalstudents from student s
join department d on s.deptid = d.deptid
group by d.deptname;

select * from view_studentcountbydept;

-- Câu 5:
delimiter $$

create procedure gettopstudentsbycourse(
    in p_courseid char(6)
)
begin
    select 
        s.studentid,
        s.fullname,
        c.coursename,
        e.score
    from enrollment e
    join student s on e.studentid = s.studentid
    join course c on e.courseid = c.courseid
    where e.courseid = p_courseid
      and e.score = (
          select max(score)
          from enrollment
          where courseid = p_courseid
      );
end $$

delimiter ;
