import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["input",'results','hidden','selected','button','contains']
  static values = { url: String ,slen: Number}

  connect() {
    // console.log("Hi autopickr")
    // console.log(`URL > ${this.urlValue}`)
    // console.log(`slen > ${this.slenValue}`)

    let slen  // slen is the number of charcters entered before we search/query
    if (this.hasSlenValue) {
      this.slen = this.slenValue
    }else{
      this.slen = 1
    }
    this.inputTarget.click() // activate the autofocus target
  }

  select(){
    const selected = event.target
    // console.log(selected)
    if (this.hasButtonTarget) {  // if there is a button target, display instead of following url
      this.buttonTarget.classList.remove('hidden')
      // console.log(`selected value ${selected.innerHTML}`)
      this.inputTarget.value = selected.innerHTML
      // console.log(`selected URL ${selected.dataset.selectUrl}`)
      this.buttonTarget['href'] = selected.dataset.selectUrl
    }else{
      location.assign(selected.dataset.selectUrl)
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
    var len = this.inputTarget.value.length
    // console.log(`contain > ${this.containsTarget.checked}`)

    if (len >= this.slen) { 
      let response = await fetch(this.urlValue+`?input=${this.inputTarget.value}&contains=${this.containsTarget.checked}`);
      let data = await response.text();
      let frag = document.createRange().createContextualFragment(data);
      this.clear_results()  // set result to no children
      this.resultsTarget.appendChild(frag) // rebuild the results
    }
  }
}
