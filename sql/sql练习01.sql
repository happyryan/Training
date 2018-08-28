#　　　Student(studentNo,name,age,sex) 　　 学生表 
#　　　Course(coursrNo,name,teacherNo) 　课程表 
#　　　score(studentNo,courseNo,core) 　　　　　　　　　 成绩表 
#　　　Teacher(teacherNo,name) 　　　　　　　   教师表

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

#（3）查询所有同学的学号、姓名、选课数、总成绩 ？？？？？
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

#（7）查询学过“叶平”老师所教的所有课的同学的学号、姓名 ?????????
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

#（11）查询至少有一门课与学号为“001”的同学所学相同的同学的学号和姓名；?
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

#（13）把“score”表中“叶平”老师教的课的成绩都更改为此课程的平均成绩 ?????????
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

#（14）查询和“002”号的同学学习的课程完全相同的其他同学学号和姓名






