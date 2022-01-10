import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input",'results','button',"contains"]
  static values = { 
    url: String,
    minLen: Number,
    refId: String,
    selectUrl: String
  }

  connect() {
    // First set some optional targets/values

    // minLen defines how my characters you have to enter before a search is done
    // if you are queringing a 1000 recoreds you don't want to start on the first entered character
    this.minLen = this.hasMinLenValue  ? this.minLenValue :  1 // minLen is the number of charcters entered before we search/query
    // refId is a special option that I've used to link the target model with another model.
    // I use it to line bank transactions to accounting transaction.
    // If I recongnize the bank transaction that is recurreing, I can duplicate the accounting transaction
    // to the back transaction wiht FITID
    if (this.hasRefIdValue) {
      // Is this adding to a query string or starting with a new one
      let q = this.selectUrlValue.includes('?') ? '&' : '?'
      this.refId =  `${q}refid=${this.refIdValue}`
    }else{
      this.refId = ''
    }  

    this.inputTarget.click() // activate/focus the autofocus target
  }

  select(){
    // There was a click on one of the targets
    const selected = event.target
    this.inputTarget.value = selected.innerHTML

    // if there is a button target it is a confirm target
    // the selected url is moved to the button url had they can confirm or change the query
    if (this.hasButtonTarget) {
      this.buttonTarget.classList.remove('hidden')
      const href = this.selectUrlValue.replace('SELECTED',selected.dataset.selectedId)+this.refId
      this.buttonTarget['href'] = href

    }else{
      // its either a text only query, which has already set, or a get request
      if (selected.dataset.selectedId != undefined){
        // its a get request. set url and goto it
        const href = this.selectUrlValue.replace('SELECTED',selected.dataset.selectedId)+this.refId
        location.assign(href)
      }else{
        // its either a text request or a confirm request, just clear the results and fall thru
        this.clear_results()
      }
    }
  }

  clear_results(){
    while (this.resultsTarget.firstChild) {
      this.resultsTarget.removeChild(this.resultsTarget.firstChild);
    }
    if (this.hasButtonTarget) {
      this.buttonTarget.classList.add('hidden')
    }
  }

  async search(){
    // another optional feature the tell the query to do a starts_with or contains query
    if (this.hasContainsTarget && this.containsTarget.checked) {
      this.checked = true
    }else{
      this.checked = false
    }
    // do the query or fall through
    var len = this.inputTarget.value.length
    if (len >= this.minLen) {
      let response = await fetch(this.urlValue+`?input=${this.inputTarget.value}&contains=${this.checked}`);
      let data = await response.text();
      let frag = document.createRange().createContextualFragment(data);
      this.clear_results()
      this.resultsTarget.appendChild(frag)
    }else{
      this.clear_results() // clear results on backspace < minLen
    }
  }

}
