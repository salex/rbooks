// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "page" ]

  connect() {
    const pages = this.pageTargets
    for (var i = 0;  i < pages.length; i++) {
      pages[i].classList.remove('w3-show')
      pages[i].classList.add('w3-hide')
    }
    pages[0].classList.add('w3-show')
    console.log('about')
  }

  goTo(){
    const pages = this.pageTargets
    const goto = event.target
    const url = goto.dataset.url
    console.log(url)
    let showMe
    for (var i = 0;  i < pages.length; i++) {
      pages[i].classList.remove('w3-show')
      pages[i].classList.add('w3-hide')
      if (pages[i].id == url) {
        showMe = pages[i]
      }
    }
    showMe.classList.add('w3-show')
    
  }
}
