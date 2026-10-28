<?php

class TaskRepository
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    private function baseQuery(): string
    {
        return 'SELECT tasks.*, subjects.name AS subject_name FROM tasks
                LEFT JOIN subjects ON subjects.id = tasks.subject_id';
    }

    public function all(): array
    {
        $stmt = $this->db->query($this->baseQuery() . ' ORDER BY tasks.due_date ASC');
        return $stmt->fetchAll();
    }

    public function find(int $id): ?array
    {
        $stmt = $this->db->prepare($this->baseQuery() . ' WHERE tasks.id = :id');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row === false ? null : $row;
    }

    public function create(array $data): array
    {
        $stmt = $this->db->prepare(
            'INSERT INTO tasks (title, description, subject_id, due_date, priority, status, created_at)
             VALUES (:title, :description, :subject_id, :due_date, :priority, :status, NOW())'
        );
        $stmt->execute([
            'title' => $data['title'],
            'description' => $data['description'] ?? '',
            'subject_id' => $data['subject_id'],
            'due_date' => $data['due_date'],
            'priority' => $data['priority'] ?? 'Low',
            'status' => $data['status'] ?? 'Pending',
        ]);
        $id = (int) $this->db->lastInsertId();
        return $this->find($id);
    }

    public function update(int $id, array $data): ?array
    {
        $stmt = $this->db->prepare(
            'UPDATE tasks SET title = :title, description = :description, subject_id = :subject_id,
             due_date = :due_date, priority = :priority, status = :status WHERE id = :id'
        );
        $stmt->execute([
            'title' => $data['title'],
            'description' => $data['description'] ?? '',
            'subject_id' => $data['subject_id'],
            'due_date' => $data['due_date'],
            'priority' => $data['priority'] ?? 'Low',
            'status' => $data['status'] ?? 'Pending',
            'id' => $id,
        ]);
        return $this->find($id);
    }

    public function delete(int $id): void
    {
        $stmt = $this->db->prepare('DELETE FROM tasks WHERE id = :id');
        $stmt->execute(['id' => $id]);
    }

    public function countByStatus(string $status): int
    {
        $stmt = $this->db->prepare('SELECT COUNT(*) AS total FROM tasks WHERE status = :status');
        $stmt->execute(['status' => $status]);
        return (int) $stmt->fetch()['total'];
    }

    public function countAll(): int
    {
        $stmt = $this->db->query('SELECT COUNT(*) AS total FROM tasks');
        return (int) $stmt->fetch()['total'];
    }

    public function todayPriorities(int $limit = 5): array
    {
        $stmt = $this->db->prepare(
            'SELECT id, title, priority, due_date FROM tasks
             WHERE status != :completed AND due_date >= CURDATE()
             ORDER BY CASE priority WHEN \'High\' THEN 1 WHEN \'Medium\' THEN 2 ELSE 3 END, due_date ASC
             LIMIT :limit'
        );
        $stmt->bindValue('completed', 'Completed');
        $stmt->bindValue('limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }
}
