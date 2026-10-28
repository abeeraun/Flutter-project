<?php

class Database
{
    private static ?PDO $instance = null;

    public static function getConnection(): PDO
    {
        if (self::$instance === null) {
            // Use environment variables in production; the defaults are only for local XAMPP.
            $host = getenv('STUDYFLOW_DB_HOST') ?: '127.0.0.1';
            $dbname = getenv('STUDYFLOW_DB_NAME') ?: 'studyflow_db';
            $username = getenv('STUDYFLOW_DB_USER') ?: 'root';
            $password = getenv('STUDYFLOW_DB_PASSWORD') ?: '';
            $dsn = "mysql:host=$host;dbname=$dbname;charset=utf8mb4";
            $options = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ];
            self::$instance = new PDO($dsn, $username, $password, $options);
        }
        return self::$instance;
    }
}
