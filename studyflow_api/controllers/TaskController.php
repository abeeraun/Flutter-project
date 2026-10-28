<?php

class TaskController
{
    private TaskRepository $repository;
    private SubjectRepository $subjectRepository;

    public function __construct(TaskRepository $repository, SubjectRepository $subjectRepository)
    {
        $this->repository = $repository;
        $this->subjectRepository = $subjectRepository;
    }

    public function index(): void
    {
        Response::success($this->repository->all());
    }

    public function show(int $id): void
    {
        $task = $this->repository->find($id);
        if ($task === null) {
            Response::error('Task not found.', 404);
        }
        Response::success($task);
    }

    public function store(array $data): void
    {
        $error = Validator::requireFields($data, ['title', 'subject_id', 'due_date']);
        if ($error !== null) {
            Response::error($error, 422);
        }
        foreach ([Validator::positiveInt($data, 'subject_id'), Validator::date($data, 'due_date'), Validator::oneOf($data, 'priority', ['Low', 'Medium', 'High']), Validator::oneOf($data, 'status', ['Pending', 'In Progress', 'Completed'])] as $validationError) {
            if ($validationError !== null) {
                Response::error($validationError, 422);
            }
        }
        if ($this->subjectRepository->find((int) $data['subject_id']) === null) {
            Response::error('Selected subject does not exist.', 422);
        }
        try {
            $task = $this->repository->create($data);
            Response::success($task, 201);
        } catch (Exception $e) {
            Response::error('Unable to create task.', 500);
        }
    }

    public function update(int $id, array $data): void
    {
        $existing = $this->repository->find($id);
        if ($existing === null) {
            Response::error('Task not found.', 404);
        }
        $error = Validator::requireFields($data, ['title', 'subject_id', 'due_date']);
        if ($error !== null) {
            Response::error($error, 422);
        }
        foreach ([Validator::positiveInt($data, 'subject_id'), Validator::date($data, 'due_date'), Validator::oneOf($data, 'priority', ['Low', 'Medium', 'High']), Validator::oneOf($data, 'status', ['Pending', 'In Progress', 'Completed'])] as $validationError) {
            if ($validationError !== null) {
                Response::error($validationError, 422);
            }
        }
        if ($this->subjectRepository->find((int) $data['subject_id']) === null) {
            Response::error('Selected subject does not exist.', 422);
        }
        try {
            $task = $this->repository->update($id, $data);
            Response::success($task);
        } catch (Exception $e) {
            Response::error('Unable to update task.', 500);
        }
    }

    public function destroy(int $id): void
    {
        $existing = $this->repository->find($id);
        if ($existing === null) {
            Response::error('Task not found.', 404);
        }
        try {
            $this->repository->delete($id);
            Response::success(['deleted' => true]);
        } catch (Exception $e) {
            Response::error('Unable to delete task.', 500);
        }
    }
}
