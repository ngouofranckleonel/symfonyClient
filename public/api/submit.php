<?php

// Point d'entrée simple pour la soumission du formulaire
// Redirige vers le contrôleur Symfony

require_once __DIR__ . '/../../vendor/autoload.php';

use App\Kernel;
use Symfony\Component\HttpFoundation\Request;

$kernel = new Kernel('prod', false);
$request = Request::createFromGlobals();

// Rediriger vers le contrôleur Symfony
$request->attributes->set('_controller', 'App\Controller\UserController::submit');

$response = $kernel->handle($request);
$response->send();

$kernel->terminate($request, $response);
