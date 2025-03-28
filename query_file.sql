Use University;


-- Create the Students Table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);


-- Create the Departments Table
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);


-- Create the Faculty Table
CREATE TABLE faculty (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Create the Courses Table
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(10) NOT NULL,
    title VARCHAR(100) NOT NULL,
    credits INT NOT NULL,
    faculty_id INT,
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id)
);

-- Create the Enrollments Table
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade VARCHAR(2),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);


-- Insert sample data into departments
INSERT INTO departments (name) VALUES
('Imformation Technology '),
('Mathematics'),
('Physics'),
('Computer science')
;

-- Insert sample data into students
INSERT INTO students (first_name, last_name, date_of_birth, email) VALUES
('Alice', 'Johnson', '2001-06-15', 'alice@example.com'),
('Bob', 'Smith', '2000-02-20', 'bob@example.com'),
('Charlie', 'Brown', '1999-11-30', 'charlie@example.com'),
('Bun', 'Son', '2000-10-20', 'bun@example.com'),
('Chan', 'Da', '1999-12-30', 'chan@example.com')
;

-- Insert sample data into faculty
INSERT INTO faculty (first_name, last_name, email, department_id) VALUES
('Dr. John', 'Doe', 'john.doe@example.com', 1),
('Dr. Jane', 'Smith', 'jane.smith@example.com', 2),
('Dr. Charlie', 'White', 'charlie.white@example.com', 3);

-- Insert sample data into courses
INSERT INTO courses (code, title, credits, faculty_id) VALUES
('CS101', 'Introduction to Programming', 3, 1),
('CS102', 'Data Structures', 4, 1),
('MA101', 'Calculus I', 3, 3);

-- Insert sample data into enrollments
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(1, 1, '2023-09-01', 'A'),
(1, 2, '2023-09-01', 'B'),
(2, 1, '2023-09-01', 'C'),
(2, 3, '2023-09-01', 'B'),
(3, 2, '2023-09-01', 'A'),
(3, 3, '2023-09-01', 'D');

INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(1, 1, '2023-09-01', 'A'),
(1, 1, '2023-09-01', 'B');

DELETE FROM enrollments
WHERE student_id = 1 AND course_id = 1 AND enrollment_date = '2023-09-01' AND grade IN ('A', 'B');


SELECT * FROM enrollments WHERE course_id = 1;

-- Query 1: Retrieve all students who enrolled in a specific course (e.g., Course ID = 1)
SELECT s.student_id, s.first_name, s.last_name, e.enrollment_date, e.grade
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
WHERE e.course_id = 1;


-- Query 2: Find all faculty members in a particular department (Assuming faculty table exists)
SELECT f.faculty_id, f.first_name, f.last_name, f.email
FROM faculty f
WHERE f.department_id = 1;

-- Query 3: List all courses a particular student is enrolled in (e.g., Student ID = 1)
SELECT c.course_id, c.code, c.title, e.enrollment_date, e.grade
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
WHERE e.student_id = 1;

-- Query 4: Retrieve students who have not enrolled in any course
SELECT s.student_id, s.first_name, s.last_name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.enrollment_id IS NULL;

-- Query 5: Find the average grade of students in a specific course (e.g., Course ID = 1)
SELECT c.course_id, c.code, c.title, 
       AVG(CASE 
           WHEN e.grade = 'A' THEN 4.0
           WHEN e.grade = 'B' THEN 3.0
           WHEN e.grade = 'C' THEN 2.0
           WHEN e.grade = 'D' THEN 1.0
           ELSE 0.0
       END) AS average_grade_points
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
WHERE c.course_id = 1
GROUP BY c.course_id;

-- Create Trigger to Update Student GPA when Grade is Updated
DELIMITER //
CREATE TRIGGER update_student_gpa
AFTER UPDATE ON enrollments
FOR EACH ROW
BEGIN
    DECLARE total_points DECIMAL(10,2);
    DECLARE total_credits INT;
    
    -- Calculate total grade points and credits for the student
    SELECT SUM(
        CASE 
            WHEN e.grade = 'A' THEN 4.0 * c.credits
            WHEN e.grade = 'B' THEN 3.0 * c.credits
            WHEN e.grade = 'C' THEN 2.0 * c.credits
            WHEN e.grade = 'D' THEN 1.0 * c.credits
            ELSE 0.0
        END
    ), SUM(c.credits)
    INTO total_points, total_credits
    FROM enrollments e
    JOIN courses c ON e.course_id = c.course_id
    WHERE e.student_id = NEW.student_id AND e.grade IS NOT NULL;
    
    -- Update the GPA for the student if they have enrolled in any course
    IF total_credits > 0 THEN
        UPDATE students 
        SET gpa = total_points / total_credits
        WHERE student_id = NEW.student_id;
    END IF;
END //
DELIMITER ;

-- Create Stored Procedure to Enroll a Student in a Course
DELIMITER //
CREATE PROCEDURE enroll_student(
    IN p_student_id INT,
    IN p_course_id INT,
    IN p_enrollment_date DATE
)
BEGIN
    INSERT INTO enrollments (student_id, course_id, enrollment_date, grade)
    VALUES (p_student_id, p_course_id, p_enrollment_date, NULL);
END //
DELIMITER ;

-- Example of using the stored procedure to enroll a student in a course
CALL enroll_student(2, 3, '2023-09-01');







