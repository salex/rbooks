// hideTarget.controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // static targets = ['tbody','parent']
  connect() {
    // console.log('Hello, toggle splits!')
  }

  toggle() {
    var toggler = event.currentTarget
    // console.log('clicked')
    const splits = toggler.closest('tbody').nextElementSibling
    // console.log(splits)
    splits.classList.toggle('split-rows')
    // parent.style.display = "none"
 
  } 

}
