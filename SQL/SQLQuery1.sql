---a.	מנהל המכללה ביקש לדעת כמה סטודנטים יש לפי יחידה (מחלקה).

SELECT d.DepartmentId,d.DepartmentName, COUNT (StudentId) AS Student_Count
FROM Courses c
INNER JOIN Departments d ON c.DepartmentID = d.DepartmentId
INNER JOIN Classrooms  e ON e.CourseId = c.CourseId
GROUP BY d.DepartmentId, d.DepartmentName
ORDER BY d.DepartmentId;

---b.	המורה באנגלית צריך להתארגן וביקש לדעת כמה סטודנטים יש לו לפי כל קורס שהוא מעביר וסה"כ התלמידים בכל הקורסים שלו.

SELECT c.CourseName,COUNT (StudentId) AS Student_Count  
FROM Courses c
INNER JOIN Classrooms e ON c.CourseId = e.CourseId
WHERE TeacherId = 15
GROUP BY c.TeacherId, c.CourseName
UNION ALL
SELECT 'TOTAL', COUNT (StudentId) AS Student_Count
FROM Courses c
INNER JOIN Departments d ON c.DepartmentID = d.DepartmentId
INNER JOIN Classrooms  e ON e.CourseId = c.CourseId
WHERE DepartmentName = 'English'

---c.	המרכז למדעים רוצה להבין כמה כיתות קטנות (מתחת ל-22) וכמה גדולות צריך עבור קורסים ביחידה (מחלקה) שלו.

SELECT CLASSTYPE, COUNT (CLASSTYPE) AS CLASSNUM  
FROM (
SELECT COUNT (StudentId) AS Student_Count, c.CourseName,
		CASE WHEN COUNT (StudentId) < 22 THEN 'SMALL CLASS'
			ELSE 'BIG CLASS'
	END AS CLASSTYPE
FROM Classrooms e
INNER JOIN Courses c ON e.CourseId = c.CourseId
WHERE DepartmentId = 2
GROUP BY c.CourseName) M
GROUP BY CLASSTYPE

---d.סטודנטית שהיא פעילה פמיניסטית טוענת שהמכללה מעדיפה לקבל יותר גברים מאשר נשים. תבדקו האם הטענה מוצדקת (מבחינה כמותית, לא סטטיסטית 

SELECT Gender, COUNT (StudentId) AS Student_Count 
FROM Students
GROUP BY Gender

---e.	באיזה קורסים אחוז הגברים / הנשים הינה מעל 70%?

SELECT COUNT (F.StudentId) AS Student_Count_gender , CourseName, Gender  into table_e
FROM Courses c
INNER JOIN Classrooms e ON c.CourseId = e.CourseId
INNER JOIN students f ON e.[studentid] = f.[studentid]
GROUP BY CourseName, Gender

SELECT n.[CourseName],n.[Student_Count_gender]*1.0/count (F.StudentId)*1.0*100.0 AS Student_Count_percent 
FROM Courses c
INNER JOIN Classrooms e ON c.CourseId = e.CourseId
INNER JOIN students f ON e.[studentid] = f.[studentid]
full JOIN table_e n ON c.CourseName = n.[CourseName]
GROUP BY n.Student_Count_gender, n.Gender, n.CourseName
HAVING n.[Student_Count_gender]*1.0/count (F.StudentId)*1.0*100.0 > 70.0
ORDER BY Student_Count_percent

--f.	בכל אחד מהיחידות (מחלקות), כמה סטודנטים (מספר ואחוזים) עברו עם ציון מעל 80?
SELECT d.DepartmentId, d.DepartmentName,COUNT (StudentId) AS Student_Count  into table_f
FROM Courses c
INNER JOIN Departments d ON c.DepartmentID = d.DepartmentId
INNER JOIN Classrooms  e ON e.CourseId = c.CourseId
GROUP BY d.DepartmentId, d.DepartmentName
ORDER BY d.DepartmentId;

SELECT d.DepartmentId,d.DepartmentName, count(StudentId) as count_student80,
 (count(StudentId)*1.0/(r.[Student_Count])*1.0)*100.0 AS count_student80_PER
FROM Courses c
INNER JOIN Departments d ON c.DepartmentID = d.DepartmentId
INNER JOIN Classrooms  e ON e.CourseId = c.CourseId
INNER JOIN dbo.table_f r ON C.DepartmentId = r.DepartmentId
 WHERE degree > 80
GROUP BY d.DepartmentId, d.DepartmentName, Student_Count
ORDER BY DepartmentId

--g.	בכל אחד מהיחידות (מחלקות), כמה סטודנטים (מספר ואחוזים) לא עברו (ציון מתחת ל-60) ?

SELECT d.DepartmentId,d.DepartmentName, count(StudentId) as count_student60,
 (count(StudentId)*1.0/(r.[Student_Count])*1.0)*100.0 AS count_student60_PER
FROM Courses c
INNER JOIN Departments d ON c.DepartmentID = d.DepartmentId
INNER JOIN Classrooms  e ON e.CourseId = c.CourseId
INNER JOIN dbo.table_f r ON C.DepartmentId = r.DepartmentId
 WHERE degree < 60
GROUP BY d.DepartmentId, d.DepartmentName, Student_Count
ORDER BY DepartmentId

--h.	תדרגו את המורים לפי ממוצע הציון של הסטודנטים מהגבוהה לנמוך.

SELECT s.TeacherId,s.FirstName,s.LastName, AVG(e.degree) as ave_degree
FROM Courses c
INNER JOIN Classrooms e ON c.CourseId = e.CourseId
INNER JOIN Teachers s ON c.TeacherId = s.TeacherId
GROUP BY s.TeacherId, s.FirstName, s.LastName
ORDER BY  ave_degree DESC


 
 
	--a.	 תייצרו המראה את הקורסים, היחידות (מחלקות) עליהם משויכים, המרצה בכל קורס ומספר התלמידים רשומים בקורס

CREATE  VIEW FULLVIEW AS
SELECT c.CourseName,d.DepartmentName,s.FirstName,s.LastName, count(e.StudentId) as student_count
FROM Courses c
INNER JOIN Classrooms e ON c.CourseId = e.CourseId
INNER JOIN Departments d ON c.DepartmentID = d.DepartmentId
INNER JOIN Teachers s ON c.TeacherId = s.TeacherId
GROUP BY c.CourseName,d.DepartmentName,s.FirstName,s.LastName

SELECT * FROM FULLVIEW 


--b. תייצרו המראה את התלמידים, מס' הקורסים שהם לוקחים,הממוצע של הציונים לפי יחידה (מחלקה) והממוצע הכוללת שלהם.


SELECT f.FirstName,f.LastName, count(C.CourseName) as course_count, AVG(e.degree) AS avg_degree into table_b
FROM Courses c
INNER JOIN Classrooms e ON c.CourseId = e.CourseId
INNER JOIN Departments d ON c.DepartmentID = d.DepartmentId
INNER JOIN students f ON e.[studentid] = f.[studentid]
GROUP BY f.FirstName,f.LastName

CREATE VIEW STUD_AVG AS

SELECT d.DepartmentId, D.DepartmentName,f.FirstName,f.LastName,table_b.avg_degree, count(C.CourseName) as course_count, AVG(e.degree) AS avgCOURSE_degree
FROM Courses c
INNER JOIN Classrooms e ON c.CourseId = e.CourseId
INNER JOIN Departments d ON c.DepartmentID = d.DepartmentId
INNER JOIN students f ON e.[studentid] = f.[studentid]
INNER JOIN table_b ON F.LastName = table_b.LastName 
GROUP BY f.FirstName,f.LastName, d.DepartmentId, D.DepartmentName,table_b.avg_degree

 
 SELECT* FROM STUD_AVG