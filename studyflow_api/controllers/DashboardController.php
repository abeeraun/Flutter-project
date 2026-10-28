<?php

class DashboardController
{
    private SubjectRepository $subjectRepository;
    private TaskRepository $taskRepository;
    private ExamRepository $examRepository;

    public function __construct(
        SubjectRepository $subjectRepository,
        TaskRepository $taskRepository,
        ExamRepository $examRepository
    ) {
        $this->subjectRepository = $subjectRepository;
        $this->taskRepository = $taskRepository;
        $this->examRepository = $examRepository;
    }

    public function summary(): void
    {
        $subjectsCount = count($this->subjectRepository->all());
        $pendingTasksCount = $this->taskRepository->countByStatus('Pending')
            + $this->taskRepository->countByStatus('In Progress');
        $upcomingExamsCount = $this->examRepository->countByStatus('Upcoming');
        $totalTasks = $this->taskRepository->countAll();
        $completedTasks = $this->taskRepository->countByStatus('Completed');
        $completionRate = $totalTasks === 0 ? 0 : round(($completedTasks / $totalTasks) * 100, 1);

        Response::success([
            'subjects_count' => $subjectsCount,
            'pending_tasks_count' => $pendingTasksCount,
            'upcoming_exams_count' => $upcomingExamsCount,
            'completion_rate' => $completionRate,
            'today_priorities' => $this->taskRepository->todayPriorities(5),
            'upcoming_exams' => $this->examRepository->upcoming(5),
        ]);
    }
}
