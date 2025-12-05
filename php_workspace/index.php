<?php
require 'vendor/autoload.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Firebase\JWT\JWK;

$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if ($path === '/' || $path === '/index.php') {
    echo "Hello from PHP! Public endpoint.";
    exit;
}

if ($path === '/protected') {
    $headers = getallheaders();
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';

    if (!preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
        http_response_code(401);
        echo "Missing or invalid token";
        exit;
    }

    $jwt = $matches[1];

    try {
        // In a real app, fetch JWKS from Authentik
        // $jwksUrl = getenv('AUTHENTIK_JWKS_URL');
        // $jwks = json_decode(file_get_contents($jwksUrl), true);
        // $decoded = JWT::decode($jwt, JWK::parseKeySet($jwks));
        
        // For demo purposes, we are just decoding without signature verification 
        // if we don't have the key handy, OR we can simulate it.
        // Let's just decode the payload to show it works.
        // WARNING: Do not use this in production.
        
        $tks = explode('.', $jwt);
        if (count($tks) != 3) {
            throw new Exception('Wrong number of segments');
        }
        list($headb64, $bodyb64, $cryptob64) = $tks;
        $payload = JWT::jsonDecode(JWT::urlsafeB64Decode($bodyb64));

        header('Content-Type: application/json');
        echo json_encode([
            "message" => "Access granted",
            "user" => $payload->sub ?? 'unknown',
            "claims" => $payload
        ]);

    } catch (Exception $e) {
        http_response_code(401);
        echo "Invalid token: " . $e->getMessage();
    }
    exit;
}

http_response_code(404);
echo "Not Found";
