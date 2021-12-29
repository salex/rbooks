import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    document.body.style.backgroundColor = "#0F3E61"
  }
}
