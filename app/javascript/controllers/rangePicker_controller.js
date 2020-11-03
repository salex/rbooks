/*
  This is currently a range picker for both Reports and Accounts
  it sets from to dates that will be used by report generators
  it will respond to account date changes or month select options generating ledger in account
  It will do the same in reports where the account is varialbe
*/
import { Controller } from "stimulus"
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = [ "from_date" ,'to_date','toOptions','fromOptions','byRange','byDate','pdf','account','level']

  connect() {
    // dates are input objects, not value
    this.toDate =  this.to_dateTarget
    this.fromDate = this.from_dateTarget
  }

  toOption(){
    var toSel = this.toOptionsTarget
    this.toDate.value = toSel.value
  }

  fromOption() {
    var fromSel = this.fromOptionsTarget
    var toSel = this.toOptionsTarget
    var fromIndex = fromSel.selectedIndex
    this.fromDate.value = fromSel.value
    toSel.selectedIndex = fromIndex
    this.toDate.value = toSel.value
  }

  selectPDF(){
    var url = (event.target.value)
    //  if coming from reports, account not assigned, asign it
    console.log(url)
    if (this.hasAccountTarget) {
      const acct = this.accountTarget.value
      url += `&account=${acct}`
    }
    this.assign(url)
  }

  selectSplit(){
    var url = (event.target.value)
    //  if coming from reports, account not assigned, asign it
    if (this.hasAccountTarget) {
      const acct = this.accountTarget.value
      url += `&account=${acct}`
    }
    this.assign(url)
  }
  selectLedger(){
    var url = (event.target.value)
    this.assign(url)
  }


  selectSummary(){
    const button = event.target
    const acct = this.accountTarget.value
    var url = button.dataset.url
    url = (`${url}?account=${acct}`+ this.getFromTo())
    location.assign(url)

  }

  selectCombo(){
    const button = event.target
    const acct = this.accountTarget.value
    var url = button.dataset.url
    url = (`${url}?account=${acct}&combo=true` + this.getFromTo() + this.getLevel())
    location.assign(url)
  }

  selectPL(){
    const button = event.target
    const acct = this.accountTarget.value
    var url = button.dataset.url
    url = (`${url}?account=${acct}&combo=true` + this.getFromTo() + this.getLevel())
    location.assign(url)
  }
  selectTrialBalance(){
    const button = event.target
    const acct = this.accountTarget.value
    var url = button.dataset.url
    url = (`${url}?account=${acct}&combo=true` + this.getFromTo() + this.getLevel())
    location.assign(url)
  }
  selectAuditPDF(){
    const button = event.target
    var url = button.dataset.url
    location.assign(url)
  }

  selectAuditConfig(){
    const button = event.target
    var url = button.dataset.url
    location.assign(url)
  }
  selectAuditHTML(){
    const button = event.target
    var url = button.dataset.url
    location.assign(url)
  }

  accountSet(){
    const item = event.target
    const id = item.value

    Rails.ajax({
      url: "/reports/set_acct",
      type: "patch",
      data: "id="+id,
    })
  }

  getFromTo(){
    if (this.fromDate.value == '' || this.toDate.value == '') {
      return('')
    }
    return(`&from=${this.fromDate.value}&to=${this.toDate.value}`)
  }

  getLevel(){
    if (this.hasLevelTarget) {
      var lev = this.levelTarget.value
      if (lev == '') {
        return('')
      }
      return(`&level=${lev}`)
    }
  }

  assign(url){
    /* this is used it two places, account ledger and report
      for reports it needs an account id it gets from optioal target account
    */
    if(url.includes("fromto=1")) {
      console.log(`from ${this.fromDate.value}  to ${this.toDate.value}  url ${url}`)
      if ((this.fromDate != undefined) && (this.toDate != undefined)) {
        url = url.replace('fromto=1',`from=${this.fromDate.value}&to=${this.toDate.value}`)
        if (this.hasAccountTarget) {
          url += `&account=${this.accountTarget.value}`
        }
        location.assign(url)
      }else{
        alert('Sorry, from and to dates not set')
      }
    } else { 
      location.assign(url)
    }
  }

}
