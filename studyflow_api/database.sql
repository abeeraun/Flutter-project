CREATE DATABASE IF NOT EXISTS studyflow_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE studyflow_db;

CREATE TABLE subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    teacher VARCHAR(150) NULL,
    color VARCHAR(20) NOT NULL DEFAULT '#2196F3',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    subject_id INT NOT NULL,
    due_date DATE NOT NULL,
    priority ENUM('Low', 'Medium', 'High') NOT NULL DEFAULT 'Low',
    status ENUM('Pending', 'In Progress', 'Completed') NOT NULL DEFAULT 'Pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tasks_subject FOREIGN KEY (subject_id)
        REFERENCES subjects(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE exams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    subject_id INT NOT NULL,
    exam_date DATE NOT NULL,
    total_marks INT NOT NULL DEFAULT 100,
    obtained_marks INT NULL,
    status ENUM('Upcoming', 'Completed') NOT NULL DEFAULT 'Upcoming',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_exams_subject FOREIGN KEY (subject_id)
        REFERENCES subjects(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_tasks_subject ON tasks(subject_id);
CREATE INDEX idx_exams_subject ON exams(subject_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_exams_status ON exams(status);

INSERT INTO subjects (name, description, teacher, color) VALUES
('Database Systems', 'Relational databases and SQL', 'Dr. Al-Aghbari', '#3D5AFE'),
('Mobile Development', 'Flutter and cross-platform apps', 'Dr. Al-Aghbari', '#2ECC71');

INSERT INTO tasks (title, description, subject_id, due_date, priority, status) VALUES
('Prepare ER diagram', 'Design schema for final project', 1, CURDATE(), 'High', 'In Progress'),
('Read chapter 5', 'Normalization forms', 1, CURDATE(), 'Medium', 'Pending'),
('Build CRUD screens', 'Subjects and tasks screens', 2, CURDATE(), 'High', 'Pending');

INSERT INTO exams (title, subject_id, exam_date, total_marks, obtained_marks, status) VALUES
('Midterm Exam', 1, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 100, NULL, 'Upcoming'),
('Quiz 1', 2, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 20, 18, 'Completed');
