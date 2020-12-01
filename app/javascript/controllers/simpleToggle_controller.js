import { Controller } from "stimulus"
/* Simple toggle can be used to toggle 1 to many elements(kids)
  using w3-show and w3-hide.
*/

export default class extends Controller {
  static targets = ['kids']
  connect() {
    // console.log('Hello, simple toggle!')
  }

  toggle() {
    // console.log("got work")
    const kids = this.kidsTargets
    if (kids.length > 0) {
      for (var i = 0; i < kids.length; i++) { 
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
