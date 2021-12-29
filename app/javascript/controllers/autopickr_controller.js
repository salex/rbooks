import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autopickr"
export default class extends Controller {
  static targets = ["input",'results','selected','button',"contains"]
  static values = { url: String ,slen: Number,refid: String}

  connect() {
    // console.log("Hi autopickr")
    // console.log(`URL > ${this.urlValue}`)
    // console.log(`slen > ${this.slenValue}`)
    // console.log(`contains > ${this.hasContainsTarget}`)

    let checked = false// if a contains option is present, its in url regardless

    let slen  // slen is the number of charcters entered before we search/query
    if (this.hasSlenValue) {
      this.slen = this.slenValue
    }else{
      this.slen = 1
    }
    let refid
    if (this.hasRefidValue){
      this.refid = this.refidValue 
      this.url = this.urlValue + `?refid=${this.refid}`
      console.log(`HAS refid ${this.refid} url ${this.url}`)

    }
    this.inputTarget.click() // activate the autofocus target
  }

  select(){
    const selected = event.target
    if (this.hasButtonTarget) {
      this.buttonTarget.classList.remove('hidden')
      this.buttonTarget['href'] = selected.dataset.select
    }else{
      location.assign(selected.dataset.select)
    }
  }

  selected(){
    this.clear_results()
  }

  clear_results(){
    while (this.resultsTarget.firstChild) {
      this.resultsTarget.removeChild(this.resultsTarget.firstChild);
    }
  }

  async search(){
    if (this.hasContainsTarget && this.containsTarget.checked) {
      this.checked = true
    }else{
      this.checked = false
    }

    var len = this.inputTarget.value.length
    if (len >= this.slen) {
      let response = await fetch(this.urlValue+`?input=${this.inputTarget.value}&contains=${this.checked}`);
      let data = await response.text();
      let frag = document.createRange().createContextualFragment(data);
      this.clear_results()
      this.resultsTarget.appendChild(frag)
    }else{
      this.clear_results() // clear results on backspace < slen
    }

  }
}
