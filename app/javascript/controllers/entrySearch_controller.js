// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "hidden",'showButton','refresh','form']

  connect() {
    console.log("got a search")
  }

  addSearched() {
    var entryID = this.hiddenTarget.value
    location.assign(`/entries/duplicate/${entryID}`)
  }

  showSearched(){
    var showButton = this.showButtonTarget
    showButton.classList.toggle('w3-hide')
  }

  onPostSuccess(event) {
    // console.log("got a success")
    let [data, status, xhr] = event.detail;
    this.refreshTarget.innerHTML = xhr.response;
  }

}

