<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=UTF-8');

function respond(int $status, string $message): never
{
    http_response_code($status);
    echo json_encode(['message' => $message], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    respond(405, 'Method not allowed.');
}

if (trim((string) ($_POST['website'] ?? '')) !== '') {
    respond(200, 'Thank you. Your message has been sent.');
}

$name = trim((string) ($_POST['name'] ?? ''));
$email = trim((string) ($_POST['email'] ?? ''));
$topic = trim((string) ($_POST['topic'] ?? ''));
$message = trim((string) ($_POST['message'] ?? ''));

if ($name === '' || $message === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    respond(422, 'Please enter your name, a valid email address, and a message.');
}

if (strlen($name) > 100 || strlen($email) > 254 || strlen($topic) > 200 || strlen($message) > 5000) {
    respond(422, 'One or more fields are too long.');
}

$safeEmail = str_replace(["\r", "\n"], '', $email);
$safeTopic = str_replace(["\r", "\n"], ' ', $topic);
$subjectTopic = $safeTopic !== '' ? $safeTopic : 'General enquiry';
$subject = 'Website contact form: ' . $subjectTopic;
$encodedSubject = '=?UTF-8?B?' . base64_encode($subject) . '?=';

$body = implode("\r\n", [
    'Name: ' . $name,
    'Email: ' . $safeEmail,
    'Topic: ' . $subjectTopic,
    '',
    'Message:',
    $message,
]);

$headers = implode("\r\n", [
    'MIME-Version: 1.0',
    'Content-Type: text/plain; charset=UTF-8',
    'From: BIWC Website <lilychuang78@gmail.com>',
    'Reply-To: ' . $safeEmail,
    'X-Mailer: PHP/' . phpversion(),
]);

if (!mail('lilychuang78@gmail.com', $encodedSubject, $body, $headers)) {
    error_log('BIWC contact form: mail() returned false.');
    respond(500, 'Your message could not be sent. Please try again later.');
}

respond(200, 'Thank you. Your message has been sent.');
