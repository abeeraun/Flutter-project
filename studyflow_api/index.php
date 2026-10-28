<?php

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/utils/response.php';
require_once __DIR__ . '/utils/validator.php';
require_once __DIR__ . '/repositories/SubjectRepository.php';
require_once __DIR__ . '/repositories/TaskRepository.php';
require_once __DIR__ . '/repositories/ExamRepository.php';
require_once __DIR__ . '/controllers/SubjectController.php';
require_once __DIR__ . '/controllers/TaskController.php';
require_once __DIR__ . '/controllers/ExamController.php';
require_once __DIR__ . '/controllers/DashboardController.php';
require_once __DIR__ . '/routes/api.php';

set_exception_handler(function (Throwable $exception) {
    Response::error('Internal server error.', 500);
});

$requestUri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '';
$scriptDirectory = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
$path = str_starts_with($requestUri, $scriptDirectory)
    ? substr($requestUri, strlen($scriptDirectory))
    : $requestUri;
$path = trim($path, '/');
$segments = $path === '' ? [] : explode('/', $path);

$rawBody = file_get_contents('php://input');
$decodedBody = json_decode($rawBody, true);
$body = is_array($decodedBody) ? $decodedBody : [];

routeRequest($_SERVER['REQUEST_METHOD'], $segments, $body);
