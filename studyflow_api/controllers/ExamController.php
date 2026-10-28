<?php

class ExamController
{
    private ExamRepository $repository;
    private SubjectRepository $subjectRepository;

    public function __construct(ExamRepository $repository, SubjectRepository $subjectRepository)
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
        $exam = $this->repository->find($id);
        if ($exam === null) {
            Response::error('Exam not found.', 404);
        }
        Response::success($exam);
    }

    public function store(array $data): void
    {
        $error = Validator::requireFields($data, ['title', 'subject_id', 'exam_date']);
        if ($error !== null) {
            Response::error($error, 422);
        }
        foreach ([Validator::positiveInt($data, 'subject_id'), Validator::date($data, 'exam_date'), Validator::oneOf($data, 'status', ['Upcoming', 'Completed'])] as $validationError) {
            if ($validationError !== null) {
                Response::error($validationError, 422);
            }
        }
        $totalMarks = filter_var($data['total_marks'] ?? 100, FILTER_VALIDATE_INT);
        $obtainedMarks = isset($data['obtained_marks']) && $data['obtained_marks'] !== null && $data['obtained_marks'] !== '' ? filter_var($data['obtained_marks'], FILTER_VALIDATE_INT) : null;
        if ($totalMarks === false || $totalMarks <= 0 || ($obtainedMarks !== null && ($obtainedMarks === false || $obtainedMarks < 0 || $obtainedMarks > $totalMarks))) {
            Response::error('Marks must be valid and the obtained mark cannot exceed the total mark.', 422);
        }
        if ($this->subjectRepository->find((int) $data['subject_id']) === null) {
            Response::error('Selected subject does not exist.', 422);
        }
        try {
            $exam = $this->repository->create($data);
            Response::success($exam, 201);
        } catch (Exception $e) {
            Response::error('Unable to create exam.', 500);
        }
    }

    public function update(int $id, array $data): void
    {
        $existing = $this->repository->find($id);
        if ($existing === null) {
            Response::error('Exam not found.', 404);
        }
        $error = Validator::requireFields($data, ['title', 'subject_id', 'exam_date']);
        if ($error !== null) {
            Response::error($error, 422);
        }
        foreach ([Validator::positiveInt($data, 'subject_id'), Validator::date($data, 'exam_date'), Validator::oneOf($data, 'status', ['Upcoming', 'Completed'])] as $validationError) {
            if ($validationError !== null) {
                Response::error($validationError, 422);
            }
        }
        $totalMarks = filter_var($data['total_marks'] ?? 100, FILTER_VALIDATE_INT);
        $obtainedMarks = isset($data['obtained_marks']) && $data['obtained_marks'] !== null && $data['obtained_marks'] !== '' ? filter_var($data['obtained_marks'], FILTER_VALIDATE_INT) : null;
        if ($totalMarks === false || $totalMarks <= 0 || ($obtainedMarks !== null && ($obtainedMarks === false || $obtainedMarks < 0 || $obtainedMarks > $totalMarks))) {
            Response::error('Marks must be valid and the obtained mark cannot exceed the total mark.', 422);
        }
        if ($this->subjectRepository->find((int) $data['subject_id']) === null) {
            Response::error('Selected subject does not exist.', 422);
        }
        try {
            $exam = $this->repository->update($id, $data);
            Response::success($exam);
        } catch (Exception $e) {
            Response::error('Unable to update exam.', 500);
        }
    }

    public function destroy(int $id): void
    {
        $existing = $this->repository->find($id);
        if ($existing === null) {
            Response::error('Exam not found.', 404);
        }
        try {
            $this->repository->delete($id);
            Response::success(['deleted' => true]);
        } catch (Exception $e) {
            Response::error('Unable to delete exam.', 500);
        }
    }
}
