#　　　Student(studentNo,name,age,sex) 　　 学生表 
#　　　Course(coursrNo,name,teacherNo) 　课程表 
#　　　score(studentNo,courseNo,core) 　成绩表 
#　　　Teacher(teacherNo,name) 　　教师表

#（1）查询“001”课程比“002”课程成绩低的所有学生的学号、001学科成绩、002学科成绩
SELECT sc1.studentNo, sc1.score, sc2.score
FROM score sc1, score sc2
WHERE sc1.StudentNo = sc2.StudentNo AND
	sc1.courseNo = '1' AND
	sc2.courseNo = '2' AND
	sc1.score < sc2.score
ORDER BY sc1.StudentNo;

#（2）查询平均成绩大于60分的同学的学号和平均成绩  -- group by与聚合函数（COUNT, SUM, AVG, MIN, or MAX）联合使用
SELECT studentNo,AVG(score)
FROM score
GROUP BY studentNo HAVING AVG(score) > 60;

#（3）查询所有同学的学号、姓名、选课数、总成绩 ★★★
SELECT st.studentNo, st.name, COUNT(courseNo), SUM(sc.score)
FROM `score` sc, student st
WHERE sc.studentNo = st.studentNo
GROUP BY st.studentNo, st.`name`;

#（4）查询姓“李”的老师的个数
SELECT COUNT(teacherNo)
FROM `teacher`
WHERE NAME LIKE '叶%';

#（5）查询没学过“叶平”老师课的同学的学号、姓名
SELECT st.`studentNo`, st.`name`
FROM student st
WHERE st.`studentNo` NOT IN
(
SELECT DISTINCT(sc.`StudentNo`)
FROM score sc, course co, teacher te
WHERE sc.courseNo = co.courseNo AND
	co.teacherNo = te.teacherNo AND
	te.name = '叶平'
);

#（6）查询学过“001”并且也学过编号“002”课程的同学的学号、姓名
SELECT st.`studentNo`, st.`name`
FROM student st
WHERE st.`studentNo` IN
(
SELECT sc1.`StudentNo`
FROM score sc1, score sc2
WHERE sc1.`StudentNo` = sc2.`StudentNo` AND
	sc1.`CourseNo` = '1' AND
	sc2.`CourseNo` = '2' 
);

#（7）查询学过“叶平”老师所教的所有课的同学的学号、姓名 ★★★
SELECT st.studentNo, st.name
FROM student st, score sc, teacher te, course co
WHERE sc.`StudentNo` = st.`studentNo` AND
	te.`teacherNo` = co.`teacherNo` AND
	sc.`CourseNo` = co.`courseNo` AND
	te.`name` = '叶平'
GROUP BY st.`StudentNo`, st.`name`
HAVING COUNT(*) = 
(
SELECT COUNT(*) FROM course c2, teacher t2
WHERE c2.`teacherNo` = t2.`teacherNo` AND
t2.`name` = '叶平'
);
	

#（8）查询课程编号“002”的成绩比课程编号“001”课程低的所有同学的学号、姓名
SELECT st.`studentNo`, st.`name`
FROM student st 
WHERE st.`studentNo` IN
(
SELECT s1.`StudentNo`
FROM score s1, score s2
WHERE s1.`CourseNo` = '1' AND
	s2.`CourseNo` = '2' AND
	s1.`StudentNo` = s2.`StudentNo` AND
	s2.`score` > s1.`score` 
);

#（9）查询有课程成绩小于60分的同学的学号、姓名 
SELECT st.studentNo, st.name
FROM student st
WHERE st.`studentNo` IN
(
SELECT DISTINCT(studentNo) FROM score
WHERE score < 60
);

#（10）查询没有学全所有课的同学的学号、姓名
SELECT st.studentNo, st.name
FROM student st
WHERE st.`studentNo` IN
(
SELECT studentNo FROM score
GROUP BY studentNo
HAVING COUNT(*) < (
			SELECT COUNT(*) FROM course
		)
);

#（11）查询至少有一门课与学号为“001”的同学所学相同的同学的学号和姓名；★
-- 排除001
SELECT st.studentNo, st.name
FROM student st
WHERE st.`studentNo` IN 
(
SELECT studentNo FROM score 
WHERE courseNo IN 
	(
		SELECT courseNo FROM score WHERE studentNo = '1'
	)
) AND
st.`studentNo` != '1';

#（12）查询至少学过学号为“001”同学所有一门课的其他同学学号和姓名；（感觉跟11题有重叠）

#（13）把“score”表中“叶平”老师教的课的成绩都更改为此课程的平均成绩 ★★★
-- MySQL:把一个表中的数据按键值更新(update)到另一个表
UPDATE score s,
	(
	SELECT sc.`CourseNo` AS num, AVG(sc.`score`) AS avgscore 
	FROM course co, score sc, teacher te
	WHERE sc.`CourseNo` = co.`courseNo` AND 
		co.`teacherNo` = te.`teacherNo` AND
		te.`name` = '叶平' 
	GROUP BY sc.`CourseNo`
	) AS t
SET s.`score` = t.avgscore
WHERE s.`CourseNo` = t.num;

#（14）查询和“002”号的同学学习的课程完全相同的其他同学学号和姓名★★★
-- 这里利用了CourseNo作为主键唯一的特性，不同人的各课程相加的值也不同，如果相同，那么所学课程必定相同。
-- 另外，课程数也一样
SELECT st.`StudentNo`, st.`name`
FROM student st
WHERE st.`studentNo` != '2' AND
	st.`StudentNo` IN 
	(
		SELECT sc1.studentNo FROM score sc1
		GROUP BY sc1.`StudentNo`
		HAVING SUM(sc1.`CourseNo`) = (
						SELECT SUM(courseNo) FROM score
						WHERE studentNo = '2'
						) 
		AND COUNT(sc1.`CourseNo`) = (
						SELECT COUNT(courseNo) FROM score
						WHERE studentNo = '2'
						) 
					
	);

#（15）删除学习“叶平”老师课的SC表记录
DELETE FROM score
WHERE courseNo IN (
			SELECT course.`courseNo`
			FROM course, teacher
			WHERE course.`teacherNo` = teacher.`teacherNo` AND
				teacher.`name` = '叶平'
			);



#（16）向SC表中插入一些记录，这些记录要求符合以下条件：1、没有上过编号“002”课程的同学学号；2、插入“002”号课程的平均成绩　★
-- 本题采用插入子查询的方式，三个字段中后两个字段为常量
INSERT INTO score (score, courseNo, studentNo)
(
SELECT (
	SELECT AVG(score) FROM score
	WHERE courseNo = '2'
	) , '2', DISTINCT(sc2.studentNo)
FROM score sc2
WHERE sc2.studentNo NOT IN (
				SELECT studentNo FROM score
				WHERE courseNo = '2'
				)
);


-- 为什么下面的查询会有两个结果？
-- 因为studentNo列本来就是有重复的，比如‘1’有两条记录
SELECT studentNo FROM score 
WHERE studentNo NOT IN (2,3,4,5,6,7);

#(17）按平均成绩从低到高显示所有学生的“语文”、“数学”、“英语”三门的课程成绩，按如下形式显示： 学生ID,语文,数学,英语,有效课程数,有效平均分 ★
-- 没上过的课的成绩会显示成null
-- 这里采用了相关子查询的方式，不会丢失值
SELECT sc.studentNo,
(SELECT s1.score FROM score s1 WHERE s1.courseNo = (SELECT c1.courseNo FROM course c1 WHERE c1.name = '语文') AND s1.studentNo = sc.`StudentNo`) AS '语文',
(SELECT s2.score FROM score s2 WHERE s2.courseNo = (SELECT c2.courseNo FROM course c2 WHERE c2.name = '数学') AND s2.studentNo = sc.`StudentNo`) AS '数学',
(SELECT s3.score FROM score s3 WHERE s3.courseNo = (SELECT c3.courseNo FROM course c3 WHERE c3.name = '英语') AND s3.studentNo = sc.`StudentNo`) AS '英语'
FROM score sc
GROUP BY sc.`StudentNo`
ORDER BY AVG(sc.`score`) ASC;

#（18）查询各科成绩最高和最低的分：以如下形式显示：课程ID，最高分，最低分；
SELECT sc.`CourseNo`, MAX(sc.`score`) AS '最高分', MIN(sc.`score`) AS '最低分'
FROM score sc
GROUP BY sc.`CourseNo`;

#（19）按各科平均成绩从低到高和及格率的百分数从高到低顺序；★★★
-- MYSQL中ISNULL和IFNULL的区别： ISNULL(expr)：if expr is NULL, returns 1, else returns 0; IFNULL(expr1, expr2)：if expr1 is not NULL, returns expr1, else returns expr2. 
SELECT sc.`CourseNo`, AVG(sc.`score`) AS '平均成绩', 
	(SELECT COUNT(*) FROM score s1 WHERE s1.courseNo = sc.courseNo AND s1.score >= 60)/(SELECT COUNT(*) FROM score s1 WHERE s1.courseNo = sc.courseNo) AS '及格率'
FROM score sc
GROUP BY sc.`CourseNo`
ORDER BY  AVG(sc.`score`) ASC,
	(SELECT COUNT(*) FROM score s1 WHERE s1.courseNo = sc.courseNo AND s1.score >= 60)/(SELECT COUNT(*) FROM score s1 WHERE s1.courseNo = sc.courseNo) DESC;

#（20）查询不同老师所教不同课程平均分从高到低显示







