import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pricing-plans-add"
export default class extends Controller {
    static targets = ["container", "template"]
    static values = {
        associationName: String,
        blueprint: String
    }

    connect() {
        this.wrapperClass = this.data.get("wrapperClass") || "nested-fields"
    }

    add(event) {
        event.preventDefault()

        const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
        this.containerTarget.insertAdjacentHTML('beforeend', content)
    }

    remove(event) {
        event.preventDefault()

        const wrapper = event.target.closest(`.${this.wrapperClass}`)
        const destroyField = wrapper.querySelector('input[name*="_destroy"]')

        if (destroyField) {
            destroyField.value = "1"
            wrapper.style.display = "none"
        } else {
            wrapper.remove()
        }
    }
}
