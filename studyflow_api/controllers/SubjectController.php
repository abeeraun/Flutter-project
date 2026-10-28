<?php

class SubjectController
{
    private SubjectRepository $repository;

    public function __construct(SubjectRepository $repository)
    {
        $this->repository = $repository;
    }

    public function index(): void
    {
        Response::success($this->repository->all());
    }

    public function show(int $id): void
    {
        $subject = $this->repository->find($id);
        if ($subject === null) {
            Response::error('Subject not found.', 404);
        }
        Response::success($subject);
    }

    public function store(array $data): void
    {
        $error = Validator::requireFields($data, ['name']);
        if ($error !== null) {
            Response::error($error, 422);
        }
        if (isset($data['color']) && !preg_match('/^#[0-9A-Fa-f]{6}$/', (string) $data['color'])) {
            Response::error('Color must be a valid hexadecimal color.', 422);
        }
        try {
            $subject = $this->repository->create($data);
            Response::success($subject, 201);
        } catch (Exception $e) {
            Response::error('Unable to create subject.', 500);
        }
    }

    public function update(int $id, array $data): void
    {
        $existing = $this->repository->find($id);
        if ($existing === null) {
            Response::error('Subject not found.', 404);
        }
        $error = Validator::requireFields($data, ['name']);
        if ($error !== null) {
            Response::error($error, 422);
        }
        if (isset($data['color']) && !preg_match('/^#[0-9A-Fa-f]{6}$/', (string) $data['color'])) {
            Response::error('Color must be a valid hexadecimal color.', 422);
        }
        try {
            $subject = $this->repository->update($id, $data);
            Response::success($subject);
        } catch (Exception $e) {
            Response::error('Unable to update subject.', 500);
        }
    }

    public function destroy(int $id): void
    {
        $existing = $this->repository->find($id);
        if ($existing === null) {
            Response::error('Subject not found.', 404);
        }
        try {
            $this->repository->delete($id);
            Response::success(['deleted' => true]);
        } catch (Exception $e) {
            Response::error('Unable to delete subject.', 500);
        }
    }
}
