// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//

import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "hidden",'showButton','fitID','modal']

  connect() {
    console.log("got a ofx autocomplete")
  }

  dupSearched() {
    const entryID = this.hiddenTarget.value
    const fitID = this.fitIDTarget.value
    location.assign(`/ofxes/matched?fit_id=${fitID}&entry_id=${entryID}`)
  }

  openModal(){
    const openButton = event.target
    const fitid = openButton.dataset.fitid
    const modal = this.modalTarget
    const modalFit = this.fitIDTarget
    modalFit.value = fitid
    console.log(modalFit)
    modal.style.display ='block'

  }

  showSearched(){
    var showButton = this.showButtonTarget
    showButton.classList.toggle('w3-hide')
  }
}
