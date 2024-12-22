-- 1.1 Database Initialization
CREATE DATABASE ASMS;
GO
USE ASMS;
GO


-- 1.2.1 Students Table
CREATE TABLE Students
(
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    PhoneNumber NVARCHAR(15),
    [Address] NVARCHAR(MAX)
);
GO


-- 1.2.2 Departments Table
CREATE TABLE Departments
(
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100) UNIQUE NOT NULL
);
GO


-- 1.2.3 Courses Table
CREATE TABLE Courses
(
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    CourseName NVARCHAR(100) NOT NULL,
    Credits INT CHECK (Credits > 0),
    DepartmentID INT
);
GO


-- 1.2.4 Teachers Table
CREATE TABLE Teachers
(
    TeacherID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    DepartmentID INT
);
GO


-- 1.2.5 Enrollments Table
CREATE TABLE Enrollments
(
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT,
    CourseID INT,
    EnrollmentDate DATE DEFAULT GETDATE(),
    Grade CHAR(2) CHECK (Grade IN ('A', 'B', 'C', 'D', 'F'))
);
GO


CREATE TABLE AuditLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    ActionType NVARCHAR(50),
    Description NVARCHAR(MAX),
    ActionDate DATETIME
);
GO


-- 1.3 Adding Foreign Keys After Table Creation

-- Add foreign key to Courses table
ALTER TABLE Courses
    ADD CONSTRAINT FK_Courses_Department 
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID) 
    ON DELETE SET NULL;

-- Add foreign key to Teachers table
ALTER TABLE Teachers
    ADD CONSTRAINT FK_Teachers_Department 
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
    ON DELETE SET NULL;

-- Add foreign key to Enrollments table for StudentID
ALTER TABLE Enrollments
    ADD CONSTRAINT FK_Enrollments_Student 
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID) 
    ON DELETE CASCADE;

-- Add foreign key to Enrollments table for CourseID
ALTER TABLE Enrollments
    ADD CONSTRAINT FK_Enrollments_Course 
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) 
    ON DELETE CASCADE;
GO


-- 2. Insert Initial Data

-- 2.1. Students Cədvəli
INSERT INTO Students
    (FirstName, LastName, BirthDate, Gender, Email, PhoneNumber, [Address])
VALUES
    ('John', 'Doe', '2000-05-15', 'Male', 'john.doe@example.com', '555-1234', '123 Elm Street, City, Country'),
    ('Jane', 'Smith', '1999-09-20', 'Female', 'jane.smith@example.com', '555-5678', '456 Oak Avenue, City, Country'),
    ('Alex', 'Johnson', '2001-03-10', 'Other', 'alex.johnson@example.com', '555-8765', '789 Pine Road, City, Country');


-- 2.2. Departments Cədvəli
INSERT INTO Departments
    (DepartmentName)
VALUES
    ('Computer Science'),
    ('Electrical Engineering'),
    ('Mathematics'),
    ('Physics');


-- 2.3. Courses Cədvəli
INSERT INTO Courses
    (CourseName, Credits, DepartmentID)
VALUES
    ('Data Structures', 3, 1),
    ('Circuits and Systems', 4, 2),
    ('Calculus I', 3, 3),
    ('Quantum Mechanics', 4, 4);


-- 2.4. Teachers Cədvəli
INSERT INTO Teachers
    (FirstName, LastName, DepartmentID)
VALUES
    ('Michael', 'Brown', 1),
    ('Emily', 'White', 2),
    ('David', 'Taylor', 3),
    ('Sarah', 'Lee', 4);


-- 2.5. Enrollments Cədvəli
INSERT INTO Enrollments
    (StudentID, CourseID, EnrollmentDate, Grade)
VALUES
    (1, 1, '2024-01-15', 'A'),
    (1, 2, '2024-01-15', 'B'),
    (2, 3, '2024-02-10', 'A'),
    (3, 4, '2024-03-05', 'C'); 


-- AGGREGATE FUNCTIONS

-- 1. Tələbələrin yaş ortalaması
SELECT AVG(DATEDIFF(YEAR, BirthDate, GETDATE())) AS AverageAge
FROM Students;

-- 2. Kurslar üzrə ümumi kredit sayı
SELECT SUM(Credits) AS TotalCredits
FROM Courses;

-- 3. Departamentdəki kursların maksimum kredit sayı
SELECT DepartmentID, MAX(Credits) AS MaxCredits
FROM Courses
GROUP BY DepartmentID;

-- 4. Departament üzrə kursların orta kredit sayı
SELECT DepartmentID, AVG(Credits) AS AverageCredits
FROM Courses
GROUP BY DepartmentID;

-- 5. Hər departamentdə olan müəllimlərin sayı
SELECT D.DepartmentName, COUNT(T.TeacherID) AS TeacherCount
FROM Departments D
LEFT JOIN Teachers T ON D.DepartmentID = T.DepartmentID
GROUP BY D.DepartmentName;

-- 6. Hər bir kursda qeydiyyatlı tələbələrin sayı
SELECT C.CourseName, COUNT(E.EnrollmentID) AS StudentCount
FROM Courses C
LEFT JOIN Enrollments E ON C.CourseID = E.CourseID
GROUP BY C.CourseName;

-- 7. Qeydiyyat tarixlərinə görə ən son qeydiyyat tarixi
SELECT MAX(EnrollmentDate) AS LatestEnrollmentDate
FROM Enrollments;

-- 8. Tələbələr arasında ən uzun adın uzunluğu
SELECT MAX(LEN(FirstName + LastName)) AS LongestNameLength
FROM Students;

-- 9. Ən yüksək qiymət alan tələbə sayı
SELECT Grade, COUNT(*) AS GradeCount
FROM Enrollments
WHERE Grade = 'A'
GROUP BY Grade;

-- 10. Bütün qeydiyyatlar üzrə orta qiymət
SELECT AVG(CASE 
            WHEN Grade = 'A' THEN 5
            WHEN Grade = 'B' THEN 4
            WHEN Grade = 'C' THEN 3
            WHEN Grade = 'D' THEN 2
            WHEN Grade = 'F' THEN 1
            ELSE 0
          END) AS AverageGrade
FROM Enrollments;


-- JOINS

-- 1. Tələbələrin qeydiyyatlı olduğu kursların siyahısı
SELECT 
    S.FirstName + ' ' + S.LastName AS StudentName,
    C.CourseName,
    E.EnrollmentDate
FROM Students S
JOIN Enrollments E ON S.StudentID = E.StudentID
JOIN Courses C ON E.CourseID = C.CourseID;

-- 2. Departamentlərdə mövcud olan müəllimlərin siyahısı
SELECT 
    D.DepartmentName,
    T.FirstName + ' ' + T.LastName AS TeacherName
FROM Departments D
LEFT JOIN Teachers T ON D.DepartmentID = T.DepartmentID;

-- 3. Kursların hansı departamentə aid olduğunu göstərən siyahı
SELECT 
    C.CourseName,
    D.DepartmentName
FROM Courses C
LEFT JOIN Departments D ON C.DepartmentID = D.DepartmentID;

-- 4. Tələbələrin hansı kurslara qeydiyyatlı olduğunu və kursun hansı departamentə aid olduğunu göstərən siyahı
SELECT 
    S.FirstName + ' ' + S.LastName AS StudentName,
    C.CourseName,
    D.DepartmentName
FROM Students S
JOIN Enrollments E ON S.StudentID = E.StudentID
JOIN Courses C ON E.CourseID = C.CourseID
LEFT JOIN Departments D ON C.DepartmentID = D.DepartmentID;

-- 5. Hər departamentdə mövcud olan kursların sayı
SELECT 
    D.DepartmentName,
    COUNT(C.CourseID) AS CourseCount
FROM Departments D
LEFT JOIN Courses C ON D.DepartmentID = C.DepartmentID
GROUP BY D.DepartmentName;

-- 6. Hər tələbənin aldığı qiymətlər və kurs adları
SELECT 
    S.FirstName + ' ' + S.LastName AS StudentName,
    C.CourseName,
    E.Grade
FROM Students S
JOIN Enrollments E ON S.StudentID = E.StudentID
JOIN Courses C ON E.CourseID = C.CourseID;

-- 7. Müəllimlərin tədris etdiyi kurslar
SELECT 
    T.FirstName + ' ' + T.LastName AS TeacherName,
    C.CourseName,
    D.DepartmentName
FROM Teachers T
JOIN Departments D ON T.DepartmentID = D.DepartmentID
LEFT JOIN Courses C ON D.DepartmentID = C.DepartmentID;

-- 8. Hər tələbənin hansı departamentin kurslarına qeydiyyatlı olduğunu göstərən siyahı
SELECT 
    S.FirstName + ' ' + S.LastName AS StudentName,
    C.CourseName,
    D.DepartmentName
FROM Students S
JOIN Enrollments E ON S.StudentID = E.StudentID
JOIN Courses C ON E.CourseID = C.CourseID
LEFT JOIN Departments D ON C.DepartmentID = D.DepartmentID;

-- 9. Kursların departamentə aid olub olmadığını yoxlayan siyahı
SELECT 
    C.CourseName,
    D.DepartmentName
FROM Courses C
LEFT JOIN Departments D ON C.DepartmentID = D.DepartmentID;

-- 10. Hansı departamentlərdə müəllim olmadığını göstərən siyahı
SELECT 
    D.DepartmentName
FROM Departments D
LEFT JOIN Teachers T ON D.DepartmentID = T.DepartmentID
WHERE T.TeacherID IS NULL;


-- SUBQUERIES

-- 1. Ən yüksək orta qiyməti olan tələbənin adını tapın
SELECT FirstName + ' ' + LastName AS StudentName
FROM Students
WHERE StudentID = (
    SELECT TOP 1 StudentID
    FROM Enrollments
    GROUP BY StudentID
    ORDER BY AVG(CASE 
                    WHEN Grade = 'A' THEN 5
                    WHEN Grade = 'B' THEN 4
                    WHEN Grade = 'C' THEN 3
                    WHEN Grade = 'D' THEN 2
                    WHEN Grade = 'F' THEN 1
                 END) DESC
);

-- 2. Tələbələrin qeydiyyatlı olduğu ən son kurs adını tapın
SELECT CourseName
FROM Courses
WHERE CourseID = (
    SELECT TOP 1 CourseID
    FROM Enrollments
    ORDER BY EnrollmentDate DESC
);

-- 3. Hər bir tələbənin ən yüksək aldığı qiyməti tapın
SELECT 
    FirstName + ' ' + LastName AS StudentName,
    (SELECT MAX(Grade) 
     FROM Enrollments E 
     WHERE E.StudentID = S.StudentID) AS MaxGrade
FROM Students S;

-- 4. Ən çox kurs keçən müəllimin adını tapın
SELECT FirstName + ' ' + LastName AS TeacherName
FROM Teachers
WHERE TeacherID = (
    SELECT TOP 1 TeacherID
    FROM Courses
    GROUP BY TeacherID
    ORDER BY COUNT(CourseID) DESC
);

-- 5. Hər bir departamentdə ən yüksək kreditli kursun adını tapın
SELECT 
    DepartmentName,
    (SELECT TOP 1 CourseName
     FROM Courses C
     WHERE C.DepartmentID = D.DepartmentID
     ORDER BY Credits DESC) AS TopCourse
FROM Departments D;

-- 6. Tələbə sayı departamentlərin orta tələbə sayından çox olan kursların adlarını tapın
SELECT CourseName
FROM Courses
WHERE CourseID IN (
    SELECT CourseID
    FROM Enrollments
    GROUP BY CourseID
    HAVING COUNT(StudentID) > (
        SELECT AVG(StudentCount)
        FROM (
            SELECT COUNT(StudentID) AS StudentCount
            FROM Enrollments
            GROUP BY CourseID
        ) AS SubQuery
    )
);

-- 7. Hər bir tələbənin ən son qeydiyyat tarixini tapın
SELECT 
    FirstName + ' ' + LastName AS StudentName,
    (SELECT MAX(EnrollmentDate) 
     FROM Enrollments E 
     WHERE E.StudentID = S.StudentID) AS LastEnrollmentDate
FROM Students S;

-- 8. Ən az müəllimi olan departamentin adını tapın
SELECT DepartmentName
FROM Departments
WHERE DepartmentID = (
    SELECT TOP 1 DepartmentID
    FROM Teachers
    GROUP BY DepartmentID
    ORDER BY COUNT(TeacherID) ASC
);

-- 9. Ən çox qeydiyyatlı tələbəsi olan kursun adını tapın
SELECT CourseName
FROM Courses
WHERE CourseID = (
    SELECT TOP 1 CourseID
    FROM Enrollments
    GROUP BY CourseID
    ORDER BY COUNT(StudentID) DESC
);

-- 10. Qeydiyyat olunan tələbələrin heç biri müəllimi olmayan departamentləri tapın
SELECT DepartmentName
FROM Departments
WHERE DepartmentID NOT IN (
    SELECT DISTINCT DepartmentID
    FROM Teachers
);

-- triggerler ucun log sistemi


-- TRIGGERS
-- 1. Tələbə qeydiyyata alındıqda log yazmaq üçün trigger
CREATE TRIGGER trg_AfterInsert_Student
ON Students
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditLog (ActionType, Description, ActionDate)
    VALUES ('Insert', 'Yeni tələbə qeydiyyatı edildi.', GETDATE());
END;
GO

-- 2. Tələbə silindikdə onun bütün qeydiyyatlarının silinməsi
CREATE TRIGGER trg_BeforeDelete_Student
ON Students
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM Enrollments WHERE StudentID IN (SELECT StudentID FROM deleted);
    DELETE FROM Students WHERE StudentID IN (SELECT StudentID FROM deleted);
END;
GO

-- 3. Yeni kurs əlavə edildikdə log yazmaq üçün trigger
CREATE TRIGGER trg_AfterInsert_Course
ON Courses
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditLog (ActionType, Description, ActionDate)
    VALUES ('Insert', 'Yeni kurs əlavə edildi.', GETDATE());
END;
GO

-- 4. Kursun kreditləri dəyişdirildikdə log yazmaq
CREATE TRIGGER trg_AfterUpdate_CourseCredits
ON Courses
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Credits)
    BEGIN
        INSERT INTO AuditLog (ActionType, Description, ActionDate)
        VALUES ('Update', 'Kursun kreditləri yeniləndi.', GETDATE());
    END
END;
GO

-- 5. Tələbənin qeydiyyat qiyməti dəyişdirildikdə log yazmaq
CREATE TRIGGER trg_AfterUpdate_EnrollmentGrade
ON Enrollments
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Grade)
    BEGIN
        INSERT INTO AuditLog (ActionType, Description, ActionDate)
        VALUES ('Update', 'Tələbənin qeydiyyat qiyməti yeniləndi.', GETDATE());
    END
END;
GO

-- 6. Yeni müəllim əlavə edildikdə log yazmaq üçün trigger
CREATE TRIGGER trg_AfterInsert_Teacher
ON Teachers
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditLog (ActionType, Description, ActionDate)
    VALUES ('Insert', 'Yeni müəllim əlavə edildi.', GETDATE());
END;
GO

-- 7. Tələbə məlumatı yeniləndikdə log yazmaq
CREATE TRIGGER trg_AfterUpdate_Student
ON Students
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditLog (ActionType, Description, ActionDate)
    VALUES ('Update', 'Tələbə məlumatları yeniləndi.', GETDATE());
END;
GO

-- 8. Hər hansı bir məlumat silindikdə ümumi log yazmaq üçün trigger
-- Trigger for Students table
CREATE TRIGGER trg_AfterDelete_Students
ON Students
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditLog (ActionType, Description, ActionDate)
    VALUES ('Delete', 'Students table - record deleted.', GETDATE());
END;
GO

-- Trigger for Teachers table
CREATE TRIGGER trg_AfterDelete_Teachers
ON Teachers
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditLog (ActionType, Description, ActionDate)
    VALUES ('Delete', 'Teachers table - record deleted.', GETDATE());
END;
GO

-- Trigger for Courses table
CREATE TRIGGER trg_AfterDelete_Courses
ON Courses
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditLog (ActionType, Description, ActionDate)
    VALUES ('Delete', 'Courses table - record deleted.', GETDATE());
END;
GO

-- Trigger for Departments table
CREATE TRIGGER trg_AfterDelete_Departments
ON Departments
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditLog (ActionType, Description, ActionDate)
    VALUES ('Delete', 'Departments table - record deleted.', GETDATE());
END;
GO

-- Trigger for Enrollments table
CREATE TRIGGER trg_AfterDelete_Enrollments
ON Enrollments
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditLog (ActionType, Description, ActionDate)
    VALUES ('Delete', 'Enrollments table - record deleted.', GETDATE());
END;
GO



-- Stored Procedures
-- 1. Yeni tələbə əlavə etmək üçün stored procedure
CREATE PROCEDURE AddStudent
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @BirthDate DATE,
    @Gender NVARCHAR(10),
    @Email NVARCHAR(100),
    @PhoneNumber NVARCHAR(15),
    @Address NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO Students (FirstName, LastName, BirthDate, Gender, Email, PhoneNumber, [Address])
    VALUES (@FirstName, @LastName, @BirthDate, @Gender, @Email, @PhoneNumber, @Address);

    SELECT SCOPE_IDENTITY() AS NewStudentID;
END;
GO

-- 2. Tələbənin məlumatlarını yeniləmək üçün stored procedure
CREATE PROCEDURE UpdateStudent
    @StudentID INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @BirthDate DATE,
    @Gender NVARCHAR(10),
    @Email NVARCHAR(100),
    @PhoneNumber NVARCHAR(15),
    @Address NVARCHAR(MAX)
AS
BEGIN
    UPDATE Students
    SET FirstName = @FirstName,
        LastName = @LastName,
        BirthDate = @BirthDate,
        Gender = @Gender,
        Email = @Email,
        PhoneNumber = @PhoneNumber,
        [Address] = @Address
    WHERE StudentID = @StudentID;
END;
GO

-- 3. Tələbəni silmək üçün stored procedure
CREATE PROCEDURE DeleteStudent
    @StudentID INT
AS
BEGIN
    DELETE FROM Enrollments WHERE StudentID = @StudentID;
    DELETE FROM Students WHERE StudentID = @StudentID;
END;
GO

-- 4. Müəllimlər siyahısını departamentə görə qaytarmaq üçün stored procedure
CREATE PROCEDURE GetTeachersByDepartment
    @DepartmentID INT
AS
BEGIN
    SELECT TeacherID, FirstName, LastName
    FROM Teachers
    WHERE DepartmentID = @DepartmentID;
END;
GO

-- 5. Tələbənin qeydiyyatlı olduğu kursları qaytarmaq üçün stored procedure
CREATE PROCEDURE GetStudentCourses
    @StudentID INT
AS
BEGIN
    SELECT C.CourseID, C.CourseName, C.Credits, E.Grade
    FROM Courses C
    INNER JOIN Enrollments E ON C.CourseID = E.CourseID
    WHERE E.StudentID = @StudentID;
END;
GO

-- 6. Yeni kurs əlavə etmək üçün stored procedure
CREATE PROCEDURE AddCourse
    @CourseName NVARCHAR(100),
    @Credits INT,
    @DepartmentID INT
AS
BEGIN
    INSERT INTO Courses (CourseName, Credits, DepartmentID)
    VALUES (@CourseName, @Credits, @DepartmentID);

    SELECT SCOPE_IDENTITY() AS NewCourseID;
END;
GO

-- 7. Kursun məlumatlarını yeniləmək üçün stored procedure
CREATE PROCEDURE UpdateCourse
    @CourseID INT,
    @CourseName NVARCHAR(100),
    @Credits INT,
    @DepartmentID INT
AS
BEGIN
    UPDATE Courses
    SET CourseName = @CourseName,
        Credits = @Credits,
        DepartmentID = @DepartmentID
    WHERE CourseID = @CourseID;
END;
GO

-- 8. Yeni tələbə qeydiyyatı əlavə etmək üçün stored procedure
CREATE PROCEDURE EnrollStudent
    @StudentID INT,
    @CourseID INT,
    @Grade CHAR(2)
AS
BEGIN
    INSERT INTO Enrollments (StudentID, CourseID, EnrollmentDate, Grade)
    VALUES (@StudentID, @CourseID, GETDATE(), @Grade);

    SELECT SCOPE_IDENTITY() AS NewEnrollmentID;
END;
GO

-- 9. Departamentlərdəki kursları qaytarmaq üçün stored procedure
CREATE PROCEDURE GetCoursesByDepartment
    @DepartmentID INT
AS
BEGIN
    SELECT CourseID, CourseName, Credits
    FROM Courses
    WHERE DepartmentID = @DepartmentID;
END;
GO

-- 10. Müəyyən bir kursda qeydiyyatlı tələbələri qaytarmaq üçün stored procedure
CREATE PROCEDURE GetStudentsByCourse
    @CourseID INT
AS
BEGIN
    SELECT S.StudentID, S.FirstName, S.LastName, E.Grade
    FROM Students S
    INNER JOIN Enrollments E ON S.StudentID = E.StudentID
    WHERE E.CourseID = @CourseID;
END;
GO


--Views
-- 1. Tələbə məlumatlarını və qeydiyyatlarını birləşdirən baxış
CREATE VIEW vw_StudentEnrollments AS
SELECT 
    S.StudentID,
    CONCAT(S.FirstName, ' ', S.LastName) AS FullName,
    S.BirthDate,
    S.Gender,
    S.Email,
    S.PhoneNumber,
    C.CourseID,
    C.CourseName,
    E.EnrollmentDate,
    E.Grade
FROM Students S
LEFT JOIN Enrollments E ON S.StudentID = E.StudentID
LEFT JOIN Courses C ON E.CourseID = C.CourseID;
GO

-- 2. Departamentlər və əlaqəli müəllimlər baxışı
CREATE VIEW vw_DepartmentTeachers AS
SELECT 
    D.DepartmentID,
    D.DepartmentName,
    T.TeacherID,
    CONCAT(T.FirstName, ' ', T.LastName) AS TeacherName
FROM Departments D
LEFT JOIN Teachers T ON D.DepartmentID = T.DepartmentID;
GO

-- 3. Departamentlərdəki kursları göstərən baxış
CREATE VIEW vw_DepartmentCourses AS
SELECT 
    D.DepartmentID,
    D.DepartmentName,
    C.CourseID,
    C.CourseName,
    C.Credits
FROM Departments D
LEFT JOIN Courses C ON D.DepartmentID = C.DepartmentID;
GO

-- 4. Kurslarda qeydiyyatlı tələbələrin siyahısını göstərən baxış
CREATE VIEW vw_CourseEnrollments AS
SELECT 
    C.CourseID,
    C.CourseName,
    C.Credits,
    CONCAT(S.FirstName, ' ', S.LastName) AS StudentName,
    S.Email,
    S.PhoneNumber,
    E.EnrollmentDate,
    E.Grade
FROM Courses C
LEFT JOIN Enrollments E ON C.CourseID = E.CourseID
LEFT JOIN Students S ON E.StudentID = S.StudentID;
GO

-- 5. Müəllimlər və tədris etdikləri kursları göstərən baxış
CREATE VIEW vw_TeacherCourses AS
SELECT 
    T.TeacherID,
    CONCAT(T.FirstName, ' ', T.LastName) AS TeacherName,
    D.DepartmentName,
    C.CourseID,
    C.CourseName,
    C.Credits
FROM Teachers T
LEFT JOIN Departments D ON T.DepartmentID = D.DepartmentID
LEFT JOIN Courses C ON D.DepartmentID = C.DepartmentID;
GO

-- 6. Tələbələr və onların ümumi qeydiyyat sayı ilə baxış
CREATE VIEW vw_StudentRegistrationSummary AS
SELECT 
    S.StudentID,
    CONCAT(S.FirstName, ' ', S.LastName) AS FullName,
    S.Email,
    S.PhoneNumber,
    COUNT(E.EnrollmentID) AS TotalEnrollments
FROM Students S
LEFT JOIN Enrollments E ON S.StudentID = E.StudentID
GROUP BY 
    S.StudentID, 
    S.FirstName, 
    S.LastName, 
    S.Email, 
    S.PhoneNumber;
GO

-- 7. Hər bir kurs üçün qeydiyyat statistikası ilə baxış
CREATE VIEW vw_CourseStatistics AS
SELECT 
    C.CourseID,
    C.CourseName,
    C.Credits,
    D.DepartmentName,
    COUNT(E.EnrollmentID) AS TotalEnrollments,
    AVG(CASE WHEN E.Grade IS NOT NULL THEN 
                CASE 
                    WHEN E.Grade = 'A' THEN 4.0
                    WHEN E.Grade = 'B' THEN 3.0
                    WHEN E.Grade = 'C' THEN 2.0
                    WHEN E.Grade = 'D' THEN 1.0
                    WHEN E.Grade = 'F' THEN 0.0
                END
            ELSE NULL END) AS AverageGPA
FROM Courses C
LEFT JOIN Enrollments E ON C.CourseID = E.CourseID
LEFT JOIN Departments D ON C.DepartmentID = D.DepartmentID
GROUP BY 
    C.CourseID, 
    C.CourseName, 
    C.Credits, 
    D.DepartmentName;
GO


-- INDEXES
-- 1. Tələbələrin Email sütunu üçün UNIQUE INDEX
CREATE UNIQUE INDEX idx_Students_Email ON Students (Email);
GO

-- 2. Tələbələrin ad və soyadlarına tez erişim üçün INDEX
CREATE INDEX idx_Students_Name ON Students (FirstName, LastName);
GO

-- 3. Kursların adlarına tez erişim üçün INDEX
CREATE INDEX idx_Courses_CourseName ON Courses (CourseName);
GO

-- 4. Kursların Departament ID-si ilə əlaqəsini sürətləndirmək üçün INDEX
CREATE INDEX idx_Courses_DepartmentID ON Courses (DepartmentID);
GO

-- 5. Müəllimlərin adlarına tez erişim üçün INDEX
CREATE INDEX idx_Teachers_Name ON Teachers (FirstName, LastName);
GO

-- 6. Müəllimlərin Departament ID-si ilə əlaqəsini sürətləndirmək üçün INDEX
CREATE INDEX idx_Teachers_DepartmentID ON Teachers (DepartmentID);
GO

-- 7. Qeydiyyat cədvəlində (Enrollments) tələbə ID-si və kurs ID-si üçün INDEX
CREATE INDEX idx_Enrollments_StudentID ON Enrollments (StudentID);
GO

CREATE INDEX idx_Enrollments_CourseID ON Enrollments (CourseID);
GO

-- 8. Departamentlərin adlarına tez erişim üçün INDEX
CREATE UNIQUE INDEX idx_Departments_DepartmentName ON Departments (DepartmentName);
GO

-- 9. Qeydiyyat tarixlərinə əsasən qeydiyyatların sürətli tapılması üçün INDEX
CREATE INDEX idx_Enrollments_EnrollmentDate ON Enrollments (EnrollmentDate);
GO

-- 10. Kurs adı və kreditləri ilə tez-tez sorğular üçün INDEX
CREATE INDEX idx_Courses_Name_Credits ON Courses (CourseName, Credits);
GO
