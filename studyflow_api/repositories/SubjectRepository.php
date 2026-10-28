<?php

class SubjectRepository
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    public function all(): array
    {
        $stmt = $this->db->query('SELECT * FROM subjects ORDER BY created_at DESC');
        return $stmt->fetchAll();
    }

    public function find(int $id): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM subjects WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row === false ? null : $row;
    }

    public function create(array $data): array
    {
        $stmt = $this->db->prepare(
            'INSERT INTO subjects (name, description, teacher, color, created_at) VALUES (:name, :description, :teacher, :color, NOW())'
        );
        $stmt->execute([
            'name' => $data['name'],
            'description' => $data['description'] ?? '',
            'teacher' => $data['teacher'] ?? '',
            'color' => $data['color'] ?? '#2196F3',
        ]);
        $id = (int) $this->db->lastInsertId();
        return $this->find($id);
    }

    public function update(int $id, array $data): ?array
    {
        $stmt = $this->db->prepare(
            'UPDATE subjects SET name = :name, description = :description, teacher = :teacher, color = :color WHERE id = :id'
        );
        $stmt->execute([
            'name' => $data['name'],
            'description' => $data['description'] ?? '',
            'teacher' => $data['teacher'] ?? '',
            'color' => $data['color'] ?? '#2196F3',
            'id' => $id,
        ]);
        return $this->find($id);
    }

    public function delete(int $id): void
    {
        $stmt = $this->db->prepare('DELETE FROM subjects WHERE id = :id');
        $stmt->execute(['id' => $id]);
    }
}
