<?php

class Validator
{
    public static function requireFields(array $data, array $fields): ?string
    {
        foreach ($fields as $field) {
            if (!array_key_exists($field, $data) || $data[$field] === null || trim((string) $data[$field]) === '') {
                return "Field '$field' is required.";
            }
        }
        return null;
    }

    public static function positiveInt(array $data, string $field): ?string
    {
        if (!isset($data[$field]) || filter_var($data[$field], FILTER_VALIDATE_INT) === false || (int) $data[$field] <= 0) {
            return "Field '$field' must be a positive integer.";
        }
        return null;
    }

    public static function date(array $data, string $field): ?string
    {
        if (!isset($data[$field]) || !is_string($data[$field])) {
            return "Field '$field' must be a valid date.";
        }
        $date = DateTime::createFromFormat('Y-m-d', $data[$field]);
        if ($date === false || $date->format('Y-m-d') !== $data[$field]) {
            return "Field '$field' must use YYYY-MM-DD format.";
        }
        return null;
    }

    public static function oneOf(array $data, string $field, array $allowed): ?string
    {
        if (!isset($data[$field]) || !in_array($data[$field], $allowed, true)) {
            return "Field '$field' has an invalid value.";
        }
        return null;
    }
}
