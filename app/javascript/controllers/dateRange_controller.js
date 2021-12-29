import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "from_date" ,'to_date','toOptions','fromOptions']
  static values = { url: String }

  connect() {
    // dates are input objects, not value
    this.fromDate = this.from_dateTarget
    this.toDate =  this.to_dateTarget
    console.log("Got a DateRange")
  }

  toOption(){
    var toSel = this.toOptionsTarget
    this.toDate.value = toSel.value
    // console.log('toOption')
  }

  fromOption() {
    var fromSel = this.fromOptionsTarget
    var toSel = this.toOptionsTarget
    var fromIndex = fromSel.selectedIndex
    this.fromDate.value = fromSel.value
    toSel.selectedIndex = fromIndex
    this.toDate.value = toSel.value
    // console.log('fromOption')
  }

  assignDisplay() {
    location.assign(`/${this.urlValue.replace('//','/')}?from=${this.fromDate.value}&to=${this.toDate.value}`)
  }

  assignPdf() {
    location.assign(`/${this.urlValue.replace('//','/register_pdf/')}?from=${this.fromDate.value}&to=${this.toDate.value}`)
  }

  assignSplit() {
    location.assign(`/${this.urlValue.replace('//','/split_register_pdf/')}?from=${this.fromDate.value}&to=${this.toDate.value}`)
  }

}
