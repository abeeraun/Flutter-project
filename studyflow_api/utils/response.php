<?php

class Response
{
    public static function json(int $statusCode, array $payload): void
    {
        http_response_code($statusCode);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($payload);
        exit;
    }

    public static function success($data, int $statusCode = 200): void
    {
        self::json($statusCode, ['success' => true, 'data' => $data]);
    }

    public static function error(string $message, int $statusCode = 400): void
    {
        self::json($statusCode, ['success' => false, 'message' => $message]);
    }
}
