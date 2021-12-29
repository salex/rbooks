
import { Controller } from "@hotwired/stimulus"
// import Rails from "@rails/ujs";

export default class extends Controller {
 
  linkTo(){
    const goto = event.target
    const url = goto.dataset.url
    location.assign(url)
  }
}
