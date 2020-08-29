R Intro - Final Exercise


library(DBI)

### In windows, Using a ODBC DNS (predefined connection name)
### Some possible strings for the driver:
### the DSN must be the same as you created in the ODBC (check it!)
driver <- "Driver={SQL Server};DSN=COLLEGE;Trusted_Connection=yes;"

driver <- "Driver={SQL Server Native Connection 11.0};DSN=COLLEGE;Trusted_Connection=True;"

### XXXXX\\XXXXX is the name of the server as it appears in the SQL server management studio
### COLLEGE is the name of the database (check how do you called it in your local server)
driver <- "Driver={SQL Server Native Connection 11.0};Server=LAPTOP-OP9ISADM;Database=COLLEGE;Trusted_Connection=True;"


### Try with the diferent driver strings to see what works for you
conn <- dbConnect(odbc::odbc, .connection_string = driver)

con <- DBI::dbConnect(odbc::odbc(), 
                      Driver = "SQL Server", 
                      Server = "LAPTOP-OP9ISADM", 
                      Database = "COLLEGE", 
                      Trusted_Connection = "True")

conn=con

Classrooms<- dbGetQuery(con, 'SELECT * FROM "COLLEGE"."dbo"."Classrooms"')
Courses<- dbGetQuery(con, 'SELECT * FROM "COLLEGE"."dbo"."Courses"')
Departments<- dbGetQuery(con, 'SELECT * FROM "COLLEGE"."dbo"."Departments"')
Students<- dbGetQuery(con, 'SELECT * FROM "COLLEGE"."dbo"."Students"')
Teachers<- dbGetQuery(con, 'SELECT * FROM "COLLEGE"."dbo"."Teachers"')

library(dplyr)
library(dbplyr)


Questions
Q1. Count the number of students on each department

cl_co_de<- Classrooms %>%
  inner_join(Courses) %>%
  inner_join(Departments)
cl_co_de

result1<- cl_co_de %>%
  group_by(DepartmentName) %>%
  summarise(count_students = n_distinct(StudentId))
result1


Q2. How many students have each course of the English department and the total number of students in the department?
  
  result2<- cl_co_de %>%
  group_by(CourseName) %>%
  filter(DepartmentName == 'English') %>%
  summarise(count_students = n_distinct(StudentId))
result2

result12<- cl_co_de %>%
  group_by(DepartmentName) %>%
  filter(DepartmentName == 'English') %>%
  summarise(count_students = n_distinct(StudentId))%>%
  rename(CourseName  = DepartmentName)
result12

result23 <- union(result2,result12)
result23

result23[result23== 'English']<- 'TOTAL'
result23


Q3. How many small (<22 students) and large (22+ students) classrooms are needed for the Science department?
  
  result3<-  cl_co_de %>%
  group_by(CourseName) %>%
  filter(DepartmentId == 2) %>%
  summarise(count_students = n_distinct(StudentId))
result3

result3<-  result3  %>%
  mutate(Classroom_type = case_when(
    count_students > 22    ~ "big class ",
    TRUE                 ~  "small class"))%>%
  group_by(Classroom_type) %>%
  tally(name = "number of classrooms")
result3


Q4. A feminist student claims that there are more male than female in the College. Justify if the argument is correct


result4<-  Students %>%
  group_by(Gender) %>%
  summarise(count_students = n_distinct(StudentId))
result4




Q5. For which courses the percentage of male/female students is over 70%?
  
  cl_co_st<- Classrooms %>%
  inner_join(Courses) %>%
  inner_join(Students)
cl_co_st

result5<-  cl_co_st %>%
  group_by(CourseId, CourseName,Gender)%>%
  summarise(count_students_gender = n())
result5

result5a<-   cl_co_st %>%
  group_by(CourseId, CourseName) %>%
  summarise(count_students = n())
result5a

result5<- result5 %>%
  inner_join(result5a, by=c("CourseId","CourseName"))
result5

result5<- result5 %>%
  group_by(CourseId) %>%
  mutate( percent= (count_students_gender*1.0/ count_students)*100.0) %>%
  select(- Gender, - count_students_gender,- count_students) %>%
  filter(percent > 70)
result5


Q6. For each department, how many students passed with a grades over 80?
  
  cl_co_de_st<- Classrooms %>%
  inner_join(Courses) %>%
  inner_join(Departments) %>%
  inner_join(Students)
cl_co_de_st

result6<- cl_co_de_st %>%
  group_by(DepartmentId, DepartmentName) %>%
  filter(degree >80) %>%
  summarise(count_students80 = n_distinct(StudentId))
result6

result6a<- result6 %>%
  inner_join(result1)
result6a

result6a<- result6a %>%
  group_by(DepartmentId, DepartmentName) %>%
  mutate( count_percent80= (count_students80/ count_students)*100.0) 
result6a




Q7. For each department, how many students passed with a grades under 60?
  
  result7<- cl_co_de_st %>%
  group_by(DepartmentId, DepartmentName) %>%
  filter(degree <60) %>%
  summarise(count_students60 = n_distinct(StudentId))
result7

result7a<- result7 %>%
  inner_join(result1)
result7a

result7a<- result7a %>%
  group_by(DepartmentId, DepartmentName) %>%
  mutate( count_percent60= (count_students60/ count_students)*100.0) 
result7a





Q8. Rate the teachers by their average student's grades (in descending order).

cl_co_te<- Classrooms %>%
  inner_join(Courses) %>%
  inner_join(Teachers)
cl_co_te

result8<- cl_co_te %>%
  group_by(FirstName, LastName) %>%
  summarise(avg_degree = mean(degree))%>%
  rename("Teacher Name"=FirstName  ," "=LastName)%>%
  arrange(desc(avg_degree))
result8




Q9. Create a dataframe showing the courses, departments they are associated with, the teacher in each course, and the number of students enrolled in the course (for each course, department and teacher show the names).

co_de_cl_te <- Courses  %>%
 inner_join(Departments) %>%
 inner_join(Classrooms) %>%
  inner_join(Teachers)
co_de_cl_te



result9<- co_de_cl_te %>%
  group_by(CourseId, CourseName, DepartmentName,FirstName,LastName) %>%
 summarise(student_number = n_distinct(StudentId))
result9



Q10. Create a dataframe showing the students, the number of courses they take, the average of the grades per class, and their overall average (for each student show the student name).


st_cl_co<- Students   %>%
  left_join(Classrooms) %>%
  left_join(Courses) 
st_cl_co

result10a<- st_cl_co %>%
  group_by(StudentId,FirstName,LastName ) %>%
  summarise(Count_Courses = n_distinct(CourseId))
result10a


r_eng<- st_cl_co %>%
  group_by(StudentId) %>%
  filter(DepartmentId == 1) %>%
  summarise(english = mean(degree))
r_eng



r_sc<- st_cl_co %>%
  group_by(StudentId) %>%
  filter(DepartmentId == 2) %>%
  summarise(Science = mean(degree))
r_sc

r_ar<- st_cl_co %>%
  group_by(StudentId) %>%
  filter(DepartmentId == 3) %>%
  summarise(Arts = mean(degree))
r_ar

r_sp<- st_cl_co %>%
  group_by(StudentId) %>%
  filter(DepartmentId == 4) %>%
  summarise(Sports = mean(degree))
r_sp

result10<- result10a   %>%
  left_join(r_eng) %>%
  left_join(r_sc) %>%
  left_join(r_ar) %>%
  left_join(r_sp)

result10

result10b<- st_cl_co %>%
  group_by(StudentId) %>%
  summarise(general_avg = mean(degree))
result10b

result10<- result10%>%
  left_join(result10b) 
result10
