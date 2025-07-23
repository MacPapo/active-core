import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="popover"
export default class extends Controller {
  static targets = ["button"];

  connect() {
    this.popover = new bootstrap.Popover(this.buttonTarget, {
      content: this.data.get("content"),
      title: this.data.get("title"),
      trigger: "hover",
      placement: "top"
    });
  }

  disconnect() {
    this.popover.dispose();
  }
}
