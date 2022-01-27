import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input",'results','button',"contains"]
  static values = { 
    url: String,
    minLen: Number,
    refId: String,
    selectUrl: String,
    contains:String
  }

  connect() {
    // First set some optional targets/values
    this.isText = !this.hasSelectUrlValue
    this.isGet = !this.isText && !this.hasButtonTarget
    this.isConfirm = !this.isText && !this.isGet

    this.minLen = this.hasMinLenValue  ? this.minLenValue :  1 
    // minLen is the number of charcters entered before we search/query
    // minLen defines how my characters you have to enter before a search is done
    // if you are queringing a 1000 recoreds you don't want to start on the first entered character
    if (!this.isText && this.hasRefIdValue) {
      // refId is a special option that I've used to link the target model with another model.
      // I use it to link a bank transactions to a accounting transaction by FITid
      let q = this.selectUrlValue.includes('?') ? '&' : '?' // Is this adding to query string or starting with a new one
      this.refId =  `${q}refid=${this.refIdValue}`
    }else{
      this.refId = ''
    }  
    this.inputTarget.click() // activate/focus the autofocus target
  }

  select(){
    // There was a click on one of the targets. Set input target to selected value
    const selected = event.target
    this.inputTarget.value = selected.innerHTML
    if (this.isConfirm) {
      // if there is a button target it is a confirm target
      // the selected url is moved to the button url, they can then confirm or change the query
      this.buttonTarget.classList.remove('hidden')
      const href = this.selectUrlValue.replace('SELECTED',selected.dataset.selectedId)+this.refId
      this.buttonTarget['href'] = href
    }else{
      // its either a text only query, which is already set and will fall through, or a get request
      if (this.isGet && selected.dataset.selectedId != undefined){
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

  // Called whever the input target is changed
  async search(){
    // another optional feature the tell the query to do a starts_with or contains query
    if ((this.hasContainsTarget && this.containsTarget.checked)
      || 
      (this.hasContainsValue && this.containsValue =="true"))
    {
      this.isContains = "&contains=true"
    }else{
      this.isContains = ""
    }

   // do the query or fall through if < minLen
    var len = this.inputTarget.value.length
    if (len >= this.minLen) {
      let response = await fetch(this.urlValue+`?input=${this.inputTarget.value}` + this.isContains);
      let data = await response.text();
      let frag = document.createRange().createContextualFragment(data);
      this.clear_results() // going to replace results
      this.resultsTarget.appendChild(frag)
    }else{
      this.clear_results() // clear results on backspace < minLen
    }
  }

}
