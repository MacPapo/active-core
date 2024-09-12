import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="agecheck"
export default class extends Controller {
    static targets = ["birthDate", "guardianSection"]

    connect() {
        this.checkAge() // Chiama checkAge alla connessione iniziale
    }

    checkAge() {
        const birthDateValue = this.birthDateTarget.value;

        // Se il campo non ha una data, nascondi la sezione del tutore legale
        if (!birthDateValue) {
            this.hideGuardianSection();
            return;
        }

        const birthDate = new Date(birthDateValue);

        if (this.isMinor(birthDate)) {
            this.showGuardianSection();
        } else {
            this.hideGuardianSection();
        }
    }

    isMinor(birthDate) {
        const today = new Date();
        let age = today.getFullYear() - birthDate.getFullYear();
        const monthDifference = today.getMonth() - birthDate.getMonth();

        // Calcolo per verificare se l'utente non ha ancora compiuto 18 anni
        if (monthDifference < 0 || (monthDifference === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }

        return age < 18;
    }

    showGuardianSection() {
        this.guardianSectionTarget.style.display = "block";
    }

    hideGuardianSection() {
        this.guardianSectionTarget.style.display = "none";
    }
}
