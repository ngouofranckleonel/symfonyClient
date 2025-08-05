<?php

namespace App\Controller;

use App\Entity\User;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Validator\Validator\ValidatorInterface;

class UserController extends AbstractController
{
    private ValidatorInterface $validator;

    public function __construct(ValidatorInterface $validator)
    {
        $this->validator = $validator;
    }

    public function submit(Request $request): JsonResponse
    {
        // Vérification du token CSRF (Point bonus)
        $token = $request->request->get('_token');
        if (empty($token)) {
            return new JsonResponse([
                'success' => false,
                'errors' => ['_token' => 'Token CSRF manquant']
            ], 400);
        }

        $user = new User();
        $errors = [];

        // Récupération et validation des données
        $fullName = $request->request->get('fullName', '');
        $email = $request->request->get('email', '');
        $phone = $request->request->get('phone', '');
        $birthDate = $request->request->get('birthDate', '');
        $address = $request->request->get('address', '');

        $user->setFullName($fullName);
        $user->setEmail($email);
        $user->setPhone($phone);
        $user->setAddress($address);

        // Validation de la date
        if (!empty($birthDate)) {
            try {
                $user->setBirthDate(new \DateTime($birthDate));
            } catch (\Exception $e) {
                $errors['birthDate'] = 'Format de date invalide';
            }
        }

        // Validation avec Symfony Validator
        $violations = $this->validator->validate($user);

        if (count($violations) > 0) {
            foreach ($violations as $violation) {
                $property = $violation->getPropertyPath();
                $errors[$property] = $violation->getMessage();
            }
        }

        // Si pas d'erreurs, sauvegarder les données
        if (empty($errors)) {
            $this->saveUserData($user);

            return new JsonResponse([
                'success' => true,
                'message' => 'Données enregistrées avec succès',
                'data' => [
                    'fullName' => $user->getFullName(),
                    'email' => $user->getEmail(),
                    'phone' => $user->getPhone(),
                    'birthDate' => $user->getBirthDate() ? $user->getBirthDate()->format('d/m/Y') : '',
                    'address' => $user->getAddress()
                ]
            ]);
        }

        return new JsonResponse([
            'success' => false,
            'errors' => $errors
        ], 400);
    }

    private function saveUserData(User $user): void
    {
        $data = [
            'timestamp' => date('Y-m-d H:i:s'),
            'fullName' => htmlspecialchars($user->getFullName()),
            'email' => htmlspecialchars($user->getEmail()),
            'phone' => htmlspecialchars($user->getPhone()),
            'birthDate' => $user->getBirthDate() ? $user->getBirthDate()->format('Y-m-d') : '',
            'address' => htmlspecialchars($user->getAddress())
        ];

        // Sauvegarde JSON (Point bonus)
        $jsonFile = $this->getParameter('kernel.project_dir') . '/var/data.json';
        $existingData = [];
        
        if (file_exists($jsonFile)) {
            $existingData = json_decode(file_get_contents($jsonFile), true) ?: [];
        }
        
        $existingData[] = $data;
        file_put_contents($jsonFile, json_encode($existingData, JSON_PRETTY_PRINT));

        // Sauvegarde CSV (Point bonus)
        $csvFile = $this->getParameter('kernel.project_dir') . '/var/data.csv';
        $isNewFile = !file_exists($csvFile);
        
        $handle = fopen($csvFile, 'a');
        
        if ($isNewFile) {
            fputcsv($handle, ['Timestamp', 'Nom Complet', 'Email', 'Téléphone', 'Date de Naissance', 'Adresse']);
        }
        
        fputcsv($handle, array_values($data));
        fclose($handle);
    }
}
