// Variables globales
let currentLanguage = "fr"
let addressTimeout
let csrfToken = ""

// Traductions
const translations = {
  fr: {
    "Formulaire d'enregistrement client": "Formulaire d'enregistrement client",
    "Client Registration Form": "Formulaire d'enregistrement client",
    "Inscription réussie !": "Inscription réussie !",
    "Registration successful!": "Inscription réussie !",
    "Nom complet:": "Nom complet:",
    "Full name:": "Nom complet:",
    "Email:": "Email:",
    "Téléphone:": "Téléphone:",
    "Phone:": "Téléphone:",
    "Date de naissance:": "Date de naissance:",
    "Birth date:": "Date de naissance:",
    "Adresse:": "Adresse:",
    "Address:": "Adresse:",
    "Nouveau formulaire": "Nouveau formulaire",
    "New form": "Nouveau formulaire",
    "Nom complet *": "Nom complet *",
    "Full name *": "Nom complet *",
    "Email *": "Email *",
    "Téléphone *": "Téléphone *",
    "Phone *": "Téléphone *",
    "Date de naissance *": "Date de naissance *",
    "Birth date *": "Date de naissance *",
    "Adresse *": "Adresse *",
    "Address *": "Adresse *",
    Enregistrer: "Enregistrer",
    Register: "Enregistrer",
    // Messages d'erreur
    "Le nom complet est obligatoire": "Le nom complet est obligatoire",
    "Le nom doit contenir entre 3 et 50 caractères": "Le nom doit contenir entre 3 et 50 caractères",
    "L'email est obligatoire": "L'email est obligatoire",
    "Format d'email invalide": "Format d'email invalide",
    "Le téléphone est obligatoire": "Le téléphone est obligaxtoire",
    "Le téléphone doit contenir entre 9 et 12 chiffres": "Le téléphone doit contenir entre 9 et 12 chiffres",
    "La date de naissance est obligatoire": "La date de naissance est obligatoire",
    "La date doit être dans le passé": "La date doit être dans le passé",
    "L'adresse est obligatoire": "L'adresse est obligatoire",
  },
  en: {
    "Formulaire d'enregistrement client": "Client Registration Form",
    "Client Registration Form": "Client Registration Form",
    "Inscription réussie !": "Registration successful!",
    "Registration successful!": "Registration successful!",
    "Nom complet:": "Full name:",
    "Full name:": "Full name:",
    "Email:": "Email:",
    "Téléphone:": "Phone:",
    "Phone:": "Phone:",
    "Date de naissance:": "Birth date:",
    "Birth date:": "Birth date:",
    "Adresse:": "Address:",
    "Address:": "Address:",
    "Nouveau formulaire": "New form",
    "New form": "New form",
    "Nom complet *": "Full name *",
    "Full name *": "Full name *",
    "Email *": "Email *",
    "Téléphone *": "Phone *",
    "Phone *": "Phone *",
    "Date de naissance *": "Birth date *",
    "Birth date *": "Birth date *",
    "Adresse *": "Address *",
    "Address *": "Address *",
    Enregistrer: "Register",
    Register: "Register",
    // Messages d'erreur
    "Le nom complet est obligatoire": "Full name is required",
    "Le nom doit contenir entre 3 et 50 caractères": "Name must be between 3 and 50 characters",
    "L'email est obligatoire": "Email is required",
    "Format d'email invalide": "Invalid email format",
    "Le téléphone est obligatoire": "Phone is required",
    "Le téléphone doit contenir entre 9 et 12 chiffres": "Phone must contain 9 to 12 digits",
    "La date de naissance est obligatoire": "Birth date is required",
    "La date doit être dans le passé": "Date must be in the past",
    "L'adresse est obligatoire": "Address is required",
  },
}

// Initialisation au chargement de la page
document.addEventListener("DOMContentLoaded", () => {
  // Application du thème selon l'heure
  applyThemeBasedOnTime()

  // Génération du token CSRF
  generateCSRFToken()

  // Initialisation de la validation du formulaire
  initFormValidation()

  // Initialisation de l'autocomplétion d'adresse
  initAddressAutocomplete()

  // Mise à jour du thème toutes les minutes
  setInterval(applyThemeBasedOnTime, 60000)

  // Restaurer les valeurs du formulaire depuis localStorage
  restoreFormValues()
})

// Gestion du thème jour/nuit selon l'heure locale
function applyThemeBasedOnTime() {
  const now = new Date()
  const hour = now.getHours()

  // Thème sombre de 18h à 6h
  if (hour >= 18 || hour < 6) {
    document.body.classList.add("dark-theme")
  } else {
    document.body.classList.remove("dark-theme")
  }
}

// Génération du token CSRF
function generateCSRFToken() {
  csrfToken = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15)
  document.getElementById("csrfToken").value = csrfToken
}

// Changement de langue (Point bonus)
function changeLanguage(lang) {
  currentLanguage = lang

  // Mise à jour des boutons de langue
  document.querySelectorAll(".lang-btn").forEach((btn) => {
    btn.classList.remove("active")
    if (btn.getAttribute("data-lang") === lang) {
      btn.classList.add("active")
    }
  })

  // Mise à jour du contenu
  updateLanguageContent()
}

function updateLanguageContent() {
  document.querySelectorAll("[data-fr][data-en]").forEach((element) => {
    const key = element.getAttribute("data-" + currentLanguage)
    if (key && translations[currentLanguage][key]) {
      element.textContent = translations[currentLanguage][key]
    }
  })

  // Mise à jour des placeholders
  const fullNameInput = document.getElementById("fullName")
  const emailInput = document.getElementById("email")
  const phoneInput = document.getElementById("phone")
  const addressInput = document.getElementById("address")

  if (fullNameInput) {
    fullNameInput.placeholder = currentLanguage === "fr" ? "Entrez votre nom complet" : "Enter your full name"
  }
  if (emailInput) {
    emailInput.placeholder = currentLanguage === "fr" ? "exemple@email.com" : "example@email.com"

  }
  if (phoneInput) {
    phoneInput.placeholder = currentLanguage === "fr" ? "0123456789" : "0123456789"

  }
  if (addressInput) {
    addressInput.placeholder =
      currentLanguage === "fr" ? "Commencez à taper votre adresse..." : "Start typing your address..."

  }
}

// Conservation des valeurs du formulaire en cas d'erreur
function saveFormValues() {
  const formData = {
    fullName: document.getElementById("fullName").value,
    email: document.getElementById("email").value,
    phone: document.getElementById("phone").value,
    birthDate: document.getElementById("birthDate").value,
    address: document.getElementById("address").value,
  }
  localStorage.setItem("formData", JSON.stringify(formData))
}

function restoreFormValues() {
  const savedData = localStorage.getItem("formData")
  if (savedData) {
    const formData = JSON.parse(savedData)
    document.getElementById("fullName").value = formData.fullName || ""
    document.getElementById("email").value = formData.email || ""
    document.getElementById("phone").value = formData.phone || ""
    document.getElementById("birthDate").value = formData.birthDate || ""
    document.getElementById("address").value = formData.address || ""
  }
}

function clearFormValues() {
  localStorage.removeItem("formData")
}

// Validation côté client
function initFormValidation() {
  const form = document.getElementById("clientForm")
  const inputs = form.querySelectorAll(".form-control")

  // Sauvegarder les valeurs à chaque modification
  inputs.forEach((input) => {
    input.addEventListener("blur", () => validateField(input))
    input.addEventListener("input", () => {
      clearFieldError(input)
      saveFormValues()
    })
  })

  form.addEventListener("submit", async (e) => {
    e.preventDefault()

    let isValid = true
    inputs.forEach((input) => {
      if (!validateField(input)) {
        isValid = false
      }
    })

    if (isValid) {
      await submitForm()
    }
  })
}

function validateField(input) {
  const fieldName = input.name
  const value = input.value.trim()
  let isValid = true
  let errorMessage = ""

  // Effacer les erreurs précédentes
  clearFieldError(input)

  switch (fieldName) {
    case "fullName":
      if (!value) {
        errorMessage = translations[currentLanguage]["Le nom complet est obligatoire"]
        isValid = false
      } else if (value.length < 3 || value.length > 50) {
        errorMessage = translations[currentLanguage]["Le nom doit contenir entre 3 et 50 caractères"]
        isValid = false
      }
      break

    case "email":
      if (!value) {
        errorMessage = translations[currentLanguage]["L'email est obligatoire"]
        isValid = false
      } else if (!isValidEmail(value)) {
        errorMessage = translations[currentLanguage]["Format d'email invalide"]
        isValid = false
      }
      break

    case "phone":
      if (!value) {
        errorMessage = translations[currentLanguage]["Le téléphone est obligatoire"]
        isValid = false
      } else if (!/^[0-9]{9,12}$/.test(value)) {
        errorMessage = translations[currentLanguage]["Le téléphone doit contenir entre 9 et 12 chiffres"]
        isValid = false
      }
      break

    case "birthDate":
      if (!value) {
        errorMessage = translations[currentLanguage]["La date de naissance est obligatoire"]
        isValid = false
      } else if (new Date(value) >= new Date()) {
        errorMessage = translations[currentLanguage]["La date doit être dans le passé"]
        isValid = false
      }
      break

    case "address":
      if (!value) {
        errorMessage = translations[currentLanguage]["L'adresse est obligatoire"]
        isValid = false
      }
      break
  }

  if (!isValid) {
    showFieldError(input, errorMessage)
    input.classList.add("error")
    input.classList.remove("valid")
  } else {
    input.classList.add("valid")
    input.classList.remove("error")
  }

  return isValid
}

function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

function showFieldError(input, message) {
  const errorElement = document.getElementById(input.name + "-error")
  if (errorElement) {
    errorElement.textContent = message
    errorElement.classList.add("show")
  }
}

function clearFieldError(input) {
  const errorElement = document.getElementById(input.name + "-error")
  if (errorElement) {
    errorElement.textContent = ""
    errorElement.classList.remove("show")
  }
}

// Soumission du formulaire
async function submitForm() {
  const formData = new FormData()
  formData.append("fullName", document.getElementById("fullName").value)
  formData.append("email", document.getElementById("email").value)
  formData.append("phone", document.getElementById("phone").value)
  formData.append("birthDate", document.getElementById("birthDate").value)
  formData.append("address", document.getElementById("address").value)
  formData.append("_token", csrfToken)

  try {
    const response = await fetch("api/submit.php", {
      method: "POST",
      body: formData,
    })

    const result = await response.json()

    if (result.success) {
      showSuccessMessage(result.data)
      clearFormValues()
    } else {
      // Afficher les erreurs serveur
      if (result.errors) {
        Object.keys(result.errors).forEach((field) => {
          const input = document.getElementById(field)
          if (input) {
            showFieldError(input, result.errors[field])
            input.classList.add("error")
          }
        })
      }
    }
  } catch (error) {
    console.error("Erreur lors de la soumission:", error)
    alert("Une erreur est survenue lors de la soumission du formulaire.")
  }
}

// Affichage du résumé sécurisé des données
function showSuccessMessage(data) {
  const form = document.getElementById("clientForm")
  const successMessage = document.getElementById("successMessage")
  const userSummary = document.getElementById("userSummary")

  // Créer le résumé sécurisé
  userSummary.innerHTML = `
    <p><strong data-fr="Nom complet:" data-en="Full name:">Nom complet:</strong> ${escapeHtml(data.fullName)}</p>
    <p><strong data-fr="Email:" data-en="Email:">Email:</strong> ${escapeHtml(data.email)}</p>
    <p><strong data-fr="Téléphone:" data-en="Phone:">Téléphone:</strong> ${escapeHtml(data.phone)}</p>
    <p><strong data-fr="Date de naissance:" data-en="Birth date:">Date de naissance:</strong> ${escapeHtml(data.birthDate)}</p>
    <p><strong data-fr="Adresse:" data-en="Address:">Adresse:</strong> ${escapeHtml(data.address)}</p>
  `

  form.style.display = "none"
  successMessage.style.display = "block"

  // Mettre à jour les traductions
  updateLanguageContent()
}

function escapeHtml(text) {
  const div = document.createElement("div")
  div.textContent = text
  return div.innerHTML
}

function resetForm() {
  const form = document.getElementById("clientForm")
  const successMessage = document.getElementById("successMessage")

  form.reset()
  form.style.display = "block"
  successMessage.style.display = "none"

  // Nettoyer les classes de validation
  document.querySelectorAll(".form-control").forEach((input) => {
    input.classList.remove("valid", "error")
    clearFieldError(input)
  })

  // Générer un nouveau token CSRF
  generateCSRFToken()
}

// Autocomplétion d'adresse avec OpenStreetMap
function initAddressAutocomplete() {
  const addressInput = document.getElementById("address")
  const suggestionsContainer = document.getElementById("addressSuggestions")

  addressInput.addEventListener("input", function () {
    const query = this.value.trim()

    clearTimeout(addressTimeout)

    if (query.length < 3) {
      hideSuggestions()
      return
    }

    addressTimeout = setTimeout(() => {
      searchAddresses(query)
    }, 300)
  })

  // Fermer les suggestions en cliquant ailleurs
  document.addEventListener("click", (e) => {
    if (!addressInput.contains(e.target) && !suggestionsContainer.contains(e.target)) {
      hideSuggestions()
    }
  })
}

async function searchAddresses(query) {
  const suggestionsContainer = document.getElementById("addressSuggestions")

  try {
    // Afficher un indicateur de chargement
    suggestionsContainer.innerHTML = '<div class="loading-suggestions">Recherche...</div>'
    suggestionsContainer.style.display = "block"

    const response = await fetch(
      `https://photon.komoot.io/api/?q=${encodeURIComponent(query)}&limit=5&lang=${currentLanguage}`,
    )
    const data = await response.json()

    displayAddressSuggestions(data.features)
  } catch (error) {
    console.error("Erreur lors de la recherche d'adresse:", error)
    hideSuggestions()
  }
}

function displayAddressSuggestions(features) {
  const suggestionsContainer = document.getElementById("addressSuggestions")

  if (!features || features.length === 0) {
    hideSuggestions()
    return
  }

  suggestionsContainer.innerHTML = ""

  features.forEach((feature) => {
    const suggestion = document.createElement("div")
    suggestion.className = "address-suggestion"

    const properties = feature.properties
    let addressText = ""

    if (properties.name) addressText += properties.name
    if (properties.street) addressText += (addressText ? ", " : "") + properties.street
    if (properties.city) addressText += (addressText ? ", " : "") + properties.city
    if (properties.postcode) addressText += (addressText ? " " : "") + properties.postcode
    if (properties.country) addressText += (addressText ? ", " : "") + properties.country

    suggestion.textContent = addressText

    suggestion.addEventListener("click", () => {
      document.getElementById("address").value = addressText
      hideSuggestions()
      validateField(document.getElementById("address"))
      saveFormValues()
    })

    suggestionsContainer.appendChild(suggestion)
  })

  suggestionsContainer.style.display = "block"
}

function hideSuggestions() {
  const suggestionsContainer = document.getElementById("addressSuggestions")
  if (suggestionsContainer) {
    suggestionsContainer.style.display = "none"
    suggestionsContainer.innerHTML = ""
  }
}
