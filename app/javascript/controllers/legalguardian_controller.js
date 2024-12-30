import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="legalguardian"
export default class extends Controller {
    static targets = ["email", "name", "surname", "phone", "birthDay"]

    findGuardian() {
        const email = this.emailTarget.value

        console.log("Finding guardian with email:", email);

        if (email === "") {
            this.clearFields()
            return
        }

        fetch(`/legal_guardians/find_by_email?email=${email}`)
            .then(response => response.json())
            .then(data => {
                if (data.found) {
                    this.populateFields(data.legal_guardian)
                } else {
                    this.clearFields()
                }
            })
            .catch(error => {
                console.error("Error fetching Legal Guardian:", error)
                this.clearFields()
            })
    }

    populateFields(guardian) {
        this.nameTarget.value = guardian.name
        this.surnameTarget.value = guardian.surname
        this.phoneTarget.value = guardian.phone
        this.birthDayTarget.value = guardian.birth_day
    }

    clearFields() {
        this.nameTarget.value = ""
        this.surnameTarget.value = ""
        this.phoneTarget.value = ""
        this.birthDayTarget.value = ""
    }
}
