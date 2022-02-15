import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["menu"]

  connect(){
    // console.log("got a toggleMenu")
  }

  toggleMenu() {
    this.menuTarget.classList.toggle('hidden');
    // if( elem.classList.contains('fa-toggle-off')){
    //   elem.classList.add('fa-toggle-on')
    //   elem.classList.remove('fa-toggle-off')
    // }else{
    //   elem.classList.add('fa-toggle-off')
    //   elem.classList.remove('fa-toggle-on')
    // }

  }
}
