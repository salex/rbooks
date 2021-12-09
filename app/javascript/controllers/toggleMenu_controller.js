 import { Controller } from "@hotwired/stimulus"

 // Connects to data-controller="toggle"
 export default class extends Controller {
     static targets = ["menu"]

     connect(){
       // console.log("got a toggleMenu")
     }

     toggleMenu() {
         this.menuTarget.classList.toggle('hidden');
     }
 }
