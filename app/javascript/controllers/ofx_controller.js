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
  static targets = [ "hidden",'showButton','fitID','modal']

  connect() {
    console.log("got a ofx autocomplete")
  }

  dupSearched() {
    console.log( "searched")
    var entryID = this.hiddenTarget.value
    console.log(entryID)
    var fitID = this.fitIDTarget.value
    location.assign(`/ofxes/matched?fit_id=${fitID}&entry_id=${entryID}`)

    // var form = this.addForm
    // var id_input = this.player_id
    // var status = this.statusTarget
    // id_input.value = playerID
    // status.classList.toggle('w3-hide')
    // form.classList.toggle('w3-hide')
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
