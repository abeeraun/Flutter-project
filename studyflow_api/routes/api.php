<?php

function routeRequest(string $method, array $segments, array $body): void
{
    $db = Database::getConnection();
    $subjectRepository = new SubjectRepository($db);
    $taskRepository = new TaskRepository($db);
    $examRepository = new ExamRepository($db);

    $resource = $segments[0] ?? '';
    $identifier = $segments[1] ?? null;
    $sub = $segments[2] ?? null;

    if ($resource === 'subjects') {
        $controller = new SubjectController($subjectRepository);
        if ($method === 'GET' && $identifier === null) {
            $controller->index();
        } elseif ($method === 'GET' && $identifier !== null) {
            $controller->show((int) $identifier);
        } elseif ($method === 'POST' && $identifier === null) {
            $controller->store($body);
        } elseif ($method === 'PUT' && $identifier !== null) {
            $controller->update((int) $identifier, $body);
        } elseif ($method === 'DELETE' && $identifier !== null) {
            $controller->destroy((int) $identifier);
        } else {
            Response::error('Route not found.', 404);
        }
        return;
    }

    if ($resource === 'tasks') {
        $controller = new TaskController($taskRepository, $subjectRepository);
        if ($method === 'GET' && $identifier === null) {
            $controller->index();
        } elseif ($method === 'GET' && $identifier !== null) {
            $controller->show((int) $identifier);
        } elseif ($method === 'POST' && $identifier === null) {
            $controller->store($body);
        } elseif ($method === 'PUT' && $identifier !== null) {
            $controller->update((int) $identifier, $body);
        } elseif ($method === 'DELETE' && $identifier !== null) {
            $controller->destroy((int) $identifier);
        } else {
            Response::error('Route not found.', 404);
        }
        return;
    }

    if ($resource === 'exams') {
        $controller = new ExamController($examRepository, $subjectRepository);
        if ($method === 'GET' && $identifier === null) {
            $controller->index();
        } elseif ($method === 'GET' && $identifier !== null) {
            $controller->show((int) $identifier);
        } elseif ($method === 'POST' && $identifier === null) {
            $controller->store($body);
        } elseif ($method === 'PUT' && $identifier !== null) {
            $controller->update((int) $identifier, $body);
        } elseif ($method === 'DELETE' && $identifier !== null) {
            $controller->destroy((int) $identifier);
        } else {
            Response::error('Route not found.', 404);
        }
        return;
    }

    if ($resource === 'dashboard' && $identifier === 'summary') {
        $controller = new DashboardController($subjectRepository, $taskRepository, $examRepository);
        if ($method === 'GET') {
            $controller->summary();
        } else {
            Response::error('Route not found.', 404);
        }
        return;
    }

    Response::error('Route not found.', 404);
}
