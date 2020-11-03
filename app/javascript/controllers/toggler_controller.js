import { Controller } from "stimulus"
// simple controller that toggles the show/hide class of an element 
export default class extends Controller {
// this is a little overkill, but you can use it to toggle 1 to n elements with a class
  connect() {
    console.log("got a toggler")
  }

  toggleChild() {
    var elem = event.currentTarget
    var childID = elem.dataset.togglerChild
    var kids = document.getElementsByClassName('toggleMe')
    if (kids.length > 0) {
      if( elem.classList.contains('fa-toggle-off')){
        elem.classList.add('fa-toggle-on')
        elem.classList.remove('fa-toggle-off')
      }else{
        elem.classList.add('fa-toggle-off')
        elem.classList.remove('fa-toggle-on')
      }

      var i
      for (i = 0; i < kids.length; i++) { 
        if (kids[i].classList.contains('w3-hide')) {
          kids[i].classList.remove('w3-hide')
          kids[i].classList.add('w3-show')
        }else if (kids[i].classList.contains('w3-show')) {
          kids[i].classList.remove('w3-show')
          kids[i].classList.add('w3-hide')
        }else{
          kids[i].classList.toggle('w3-hide')
        }
      }
    }
  } 
}