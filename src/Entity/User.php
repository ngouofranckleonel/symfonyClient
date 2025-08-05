<?php

namespace App\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class User
{
    #[Assert\NotBlank(message: 'Le nom complet est obligatoire')]
    #[Assert\Length(
        min: 3,
        max: 50,
        minMessage: 'Le nom doit contenir au moins {{ limit }} caractères',
        maxMessage: 'Le nom ne peut pas dépasser {{ limit }} caractères'
    )]
    private ?string $fullName = null;

    #[Assert\NotBlank(message: 'L\'email est obligatoire')]
    #[Assert\Email(message: 'L\'email {{ value }} n\'est pas valide')]
    private ?string $email = null;

    #[Assert\NotBlank(message: 'Le téléphone est obligatoire')]
    #[Assert\Regex(
        pattern: '/^[0-9]{9,12}$/',
        message: 'Le téléphone doit contenir entre 9 et 12 chiffres uniquement'
    )]
    private ?string $phone = null;

    #[Assert\NotBlank(message: 'La date de naissance est obligatoire')]
    #[Assert\LessThan(
        value: 'today',
        message: 'La date de naissance doit être dans le passé'
    )]
    private ?\DateTime $birthDate = null;

    #[Assert\NotBlank(message: 'L\'adresse est obligatoire')]
    private ?string $address = null;

    // Getters and Setters
    public function getFullName(): ?string
    {
        return $this->fullName;
    }

    public function setFullName(?string $fullName): self
    {
        $this->fullName = $fullName;
        return $this;
    }

    public function getEmail(): ?string
    {
        return $this->email;
    }

    public function setEmail(?string $email): self
    {
        $this->email = $email;
        return $this;
    }

    public function getPhone(): ?string
    {
        return $this->phone;
    }

    public function setPhone(?string $phone): self
    {
        $this->phone = $phone;
        return $this;
    }

    public function getBirthDate(): ?\DateTime
    {
        return $this->birthDate;
    }

    public function setBirthDate(?\DateTime $birthDate): self
    {
        $this->birthDate = $birthDate;
        return $this;
    }

    public function getAddress(): ?string
    {
        return $this->address;
    }

    public function setAddress(?string $address): self
    {
        $this->address = $address;
        return $this;
    }
}
