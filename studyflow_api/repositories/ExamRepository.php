<?php

class ExamRepository
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    private function baseQuery(): string
    {
        return 'SELECT exams.*, subjects.name AS subject_name FROM exams
                LEFT JOIN subjects ON subjects.id = exams.subject_id';
    }

    public function all(): array
    {
        $stmt = $this->db->query($this->baseQuery() . ' ORDER BY exams.exam_date ASC');
        return $stmt->fetchAll();
    }

    public function find(int $id): ?array
    {
        $stmt = $this->db->prepare($this->baseQuery() . ' WHERE exams.id = :id');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row === false ? null : $row;
    }

    public function create(array $data): array
    {
        $stmt = $this->db->prepare(
            'INSERT INTO exams (title, subject_id, exam_date, total_marks, obtained_marks, status, created_at)
             VALUES (:title, :subject_id, :exam_date, :total_marks, :obtained_marks, :status, NOW())'
        );
        $stmt->execute([
            'title' => $data['title'],
            'subject_id' => $data['subject_id'],
            'exam_date' => $data['exam_date'],
            'total_marks' => $data['total_marks'] ?? 100,
            'obtained_marks' => $data['obtained_marks'] ?? null,
            'status' => $data['status'] ?? 'Upcoming',
        ]);
        $id = (int) $this->db->lastInsertId();
        return $this->find($id);
    }

    public function update(int $id, array $data): ?array
    {
        $stmt = $this->db->prepare(
            'UPDATE exams SET title = :title, subject_id = :subject_id, exam_date = :exam_date,
             total_marks = :total_marks, obtained_marks = :obtained_marks, status = :status WHERE id = :id'
        );
        $stmt->execute([
            'title' => $data['title'],
            'subject_id' => $data['subject_id'],
            'exam_date' => $data['exam_date'],
            'total_marks' => $data['total_marks'] ?? 100,
            'obtained_marks' => $data['obtained_marks'] ?? null,
            'status' => $data['status'] ?? 'Upcoming',
            'id' => $id,
        ]);
        return $this->find($id);
    }

    public function delete(int $id): void
    {
        $stmt = $this->db->prepare('DELETE FROM exams WHERE id = :id');
        $stmt->execute(['id' => $id]);
    }

    public function countByStatus(string $status): int
    {
        $stmt = $this->db->prepare('SELECT COUNT(*) AS total FROM exams WHERE status = :status');
        $stmt->execute(['status' => $status]);
        return (int) $stmt->fetch()['total'];
    }

    public function upcoming(int $limit = 5): array
    {
        $stmt = $this->db->prepare(
            $this->baseQuery() . ' WHERE exams.status = :status AND exams.exam_date >= CURDATE() ORDER BY exams.exam_date ASC LIMIT :limit'
        );
        $stmt->bindValue('status', 'Upcoming');
        $stmt->bindValue('limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }
}
