import { Controller } from "@hotwired/stimulus"
import debounce from "debounce";

// Connects to data-controller="usearch"
export default class extends Controller {
  initialize() {
    this.submit = debounce(this.submit.bind(this), 200);
  }

  submit() {
    this.element.requestSubmit();
  }
}
