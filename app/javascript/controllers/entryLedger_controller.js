// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 

import { Controller } from "@hotwired/stimulus"
// import Rails from '@rails/ujs';


export default class extends Controller {
  static targets = [ "splitsTbody","deletesTbody","numb" ,'description','date','transfer','debit',
  'credit','amount','balanced','submit',"theForm",'errors','deletes']

  connect() {
    let currSplits
    let currStatus
    let valid
    if (!this.haserrorsTarget){
      this.changed()
    }
  }

  changed() {
    // called when date, description, credit, debit or account changed and on connect
    // then items must be present and valid
    this.getSplits()
    this.getStatus(this.currSplits)
    this.check_valid()
  }

  getSplits() {
    let transfers = this.transferTargets
    let debits = this.debitTargets
    let credits = this.creditTargets
    let amounts = this.amountTargets
    let numbSplits = debits.length
    let deletes = this.deletesTargets
    this.currSplits = []
    for (var i = 0;  i < numbSplits; i++) {
      let split = {}
      split.sindex = i 
      // node elem
      split.$cr = credits[i]
      split.$db = debits[i]
      split.$amount = amounts[i]
      split.$acct = transfers[i]
      // do addbits on db and cr
      if (debits[i].value != '') {
        debits[i].value = this.addbits(debits[i].value)
      }
      if (credits[i].value != '') {
        credits[i].value = this.addbits(credits[i].value)
      }
      // set numbers
      split.acct = Number(transfers[i].value)
      split.db = Number(debits[i].value)
      split.cr = Number(credits[i].value)
      split.amount = Number(amounts[i].value)
      split.is_deleted = deletes[i].checked
      if (split.is_deleted === undefined){ split.is_deleted = false}

      split.valid = false
      split.blank = false
      split.incomplete = false
      split.isCredit = false
      split.isDebit = false
      split.scratch = false
      split.has_account =false
      split.has_amount = false
      this.currSplits[i] = split
    }
    // console.log(this.currSplits)
  }

  /*
   * decaffeinate suggestions:
   * DS101: Remove unnecessary use of Array.from
   * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
   */
  getStatus = function(splits) {
    // status changes after any of the 4 attributes are changed
    let status = {
      blank_row: null,
      incomplete_row: null,
      scratch_row: null,
      blank_rows: 0,
      balance: 0,
      sbalance: 0,
      valid: true
    };
    // console.log(`get rid of array from ${splits.length}`)
    // for (var s = 0;  s < splits.length; i++) {
    for (let s of Array.from(splits)) {
      this.set_split(s);
      if (s.blank) { status.blank_rows += 1; }
      if ((status.blank_row === null) && s.blank) { status.blank_row = s.sindex; }

      if ((status.incomplete_row === null) && s.incomplete && !s.is_deleted) { status.incomplete_row = s.sindex; }
      if ((status.scratch_row === null) && s.scratch) { status.scratch_row = s.sindex; }

      status.valid = status.valid && s.valid;
      if (s.is_deleted === false) {
        status.balance += s.amount
      }else{
        this.clear_split(s)
      }
      if (s.scratch) { status.sbalance += s.amount; }
    }
    this.currStatus = status
  };

  cutRow(){
    const tr = event.target.closest('tr')
    const tbody = tr.parentNode
    tbody.removeChild(tr)
    this.changed()
  }

  deleteRow(){
    // delete row is now in place, just clear the amounts and marks it red
    const checkbox = event.target
    const tbodySplits = this.splitsTbodyTarget
    const tr = checkbox.closest('tr')
    if (checkbox.checked == true) {
      tr.classList.add('deleted-row')
    } else {
      tr.classList.remove('deleted-row')
    }
    this.changed()
  }

  preventSubmit(){
    if (event.keyCode == 13) {
      event.preventDefault()
    }
  }

  submitForm(){
    // disable button to prevent double click and submit form
    this.submitTarget.setAttribute('disabled','disabled');
    this.theFormTarget.submit()
  }

  selectit(){
    event.target.select()
  }

  reconcile() {
    const sp = event.target
    const td = sp.closest('td')
    const inpt = td.querySelector('input')
    if (inpt.value === 'n') {
      inpt.value = 'c'
    }else if (inpt.value == 'c'){
      inpt.value = 'n'
    }
    sp.innerHTML = inpt.value
  }

  check_valid = function() {
    let invalid;
    let evalid =  this.entry_valid();
    if (evalid) { 
      invalid = "Entry Valid - ";
    } else {
      invalid = "Entry Invalid: Date or Desc missing - ";
    }
    const svalid = this.splits_valid(invalid);
    const button = this.submitTarget;
    if (evalid && svalid) {
      this.valid = true
      button.removeAttribute('disabled');
      button.classList.add('w3-green')
      button.classList.remove('w3-red')
      button.classList.remove('w3-disabled')

    } else {
      this.valid = false
      button.setAttribute('disabled','disabled');
      button.classList.add('w3-red')
      button.classList.remove('w3-green')
      button.classList.add('w3-disabled')

    }
  };

  entry_valid() {
    return(this.dateTarget.value !== '') && (this.descriptionTarget.value !== '')
  }
  
  splits_valid = function(evalid) {
    // console.log "START"
    let isValid;
    let balanced = this.balancedTarget;
    let balance = this.currStatus.balance
    let valid = this.currStatus.valid && (balance === 0);
    let incomplete_row = this.currStatus.incomplete_row
    if (!valid) {
      // we're goint to stuff any imbalace in a row and then toggle buttons and exit
      let imbalance_row;

      if (incomplete_row != null) {
        imbalance_row = incomplete_row;
      } else if (this.currStatus.scratch_row != null) {
        imbalance_row = this.currStatus.scratch_row;
      } else {
        imbalance_row = this.currStatus.blank_row;
      }
      // console.log(`imbalacnce row ${imbalance_row}`)
      const curr_amt = this.currSplits[imbalance_row].amount;
      const diff = curr_amt  - balance;

      // console.log "before  #{balance} c #{curr_amt} d #{diff}"
      if (diff > 0) {
        // need to offset it with a debit
        this.currSplits[imbalance_row].cr = 0;
        this.currSplits[imbalance_row].db = (diff  / 100);
        this.set_split(this.currSplits[imbalance_row]);
      } else if (diff < 0) {
        // need to offset it with a credit after abs(diff)
        this.currSplits[imbalance_row].db = 0;
        this.currSplits[imbalance_row].cr = (-diff  / 100);
        this.set_split(this.currSplits[imbalance_row]);
      } else {
        if (balance === curr_amt) {
          this.clear_split(this.currSplits[imbalance_row]);
        } else {
          alert("da problem should not happen");
        }
        // currSplits were balanced, but something added that made it balance
        // don't update split, just fall through
      }
      // lets update status in case there was a double call
      this.getSplits()
      this.getStatus(this.currSplits)

      // return(this.changed())
    }
    balance = this.currStatus.balance
    valid = this.currStatus.valid && (balance === 0);


    if (this.currStatus.valid) { 
      isValid =  `${evalid} Splits Valid: `;
    } else {
      if (this.currStatus.balance === 0) {
        isValid = this.currStatus.incomplete_row != null ? `${evalid} Splits Invalid: Account Orphaned:` : `${evalid} Splits Invalid: Account Missing:`; 
      } else {
        isValid = `${evalid} Splits Invalid: Imbalanced: `;
      }
    }
    balanced.innerHTML =(isValid+ ` Balance: (${(balance / 100).toFixed(2)})`);
    if (this.currStatus.blank_rows < 2) {
      this.addSplit();
    }

    return valid;
  };

  clearAmounts() {
    var debits = this.debitTargets
    for (var i = 0;  i < debits.length; i++) {
      this.clear_split(this.currSplits[i])
    }
    this.changed()
  }

  addSplit() {
    var splits = this.splitsTbodyTarget
    var new_tr = splits.lastChild.cloneNode(true)
    var new_tr_id  = new_tr.getAttribute('id')
    var old_numb = Number(new_tr_id.replace(/\D/g, ''))
    var new_numb = old_numb + 1
    new_tr.setAttribute('id',new_tr_id.replace(old_numb,new_numb))
    var inputs = new_tr.querySelectorAll("input")
    var selects = new_tr.querySelectorAll("select")
    new_tr.setAttribute('id',new_tr_id.replace(old_numb,new_numb))
    var i
    for (i = 0; i < inputs.length; i++) {
      var iid = inputs[i].getAttribute('id')
      var iname = inputs[i].getAttribute('name')
      inputs[i].setAttribute('id',iid.replace(old_numb,new_numb))
      inputs[i].setAttribute('name',iname.replace(old_numb,new_numb))
      if (iid.includes("reconcile")){
        inputs[i].value = 'n' 
      }else{
        inputs[i].value = '' 
      }
    }
    for (i = 0; i < selects.length; i++) {
      var iid = selects[i].getAttribute('id')
      var iname = selects[i].getAttribute('name')
      selects[i].setAttribute('id',iid.replace(old_numb,new_numb))
      selects[i].setAttribute('name',iname.replace(old_numb,new_numb))
    }
     splits.appendChild(new_tr)
  }

  clear_split = function(s) {
    s.amount = 0;
    s.cr = 0;
    s.db = 0;
    s.$cr.value = '';
    s.$db.value = '';
    s.$amount.value = '';
    this.set_state(s)
    // this.getStatus(this.currSplits)
  };

  clear_amt = function(s) {
    s.amount = 0;
    s.$amount.value = (s.amount);
    return this.set_state(s);
  };

  set_db_amount = function(s) {
    const db = Math.abs(s.db).toFixed(2);
    s.$db.value = db;
    s.$cr.value = '';
    s.cr = 0;
    const amt = db.replace('.',''); 
    s.amount = Number(amt);
    s.$amount.value = (s.amount);
    s.isDebit = true;
    return this.set_state(s);
  };

  set_cr_amount = function(s) {
    const cr = Math.abs(s.cr).toFixed(2);
    s.$cr.value = (cr);
    s.$db.value = ('');
    s.db = 0;
    const amt = cr.replace('.',''); 
    s.amount = Number(amt) * -1;
    s.$amount.value = (s.amount);
    s.isCredit = true;
    return this.set_state(s);
  };

 set_dbcr_amount = function(s) {
    // made a mistake in entering cr or db, swap amount
    if (s.amount >= 0) {
      // use cr value since db was amount used
      s.db = 0;
      return this.set_cr_amount(s);
    } else { 
      s.cr = 0;
      // use db value since cr was amount used
      return this.set_db_amount(s);
    }
  };

  // set_chg_dbcr_amount = function(s) {
  //   // assume if cr and db present, they want to replace what was auto balanced with the other value
  //   console.log('chg-dbcr-amount')
  //   const amt = Number((s.db - s.cr));

  //   if (amt >= 0) {
  //     // debit was last set, change to new credit
  //     // s.$db.val('');
  //     return this.set_cr_amount(s);
  //   } else { 
  //     // credit was last set, change to new debit
  //     s.cr = 0;
  //     return this.set_db_amount(s);
  //   }
  // };

  /*
   * decaffeinate suggestions:
   * DS102: Remove unnecessary code created because of implicit returns
   * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
   */
  set_state = function(s) {
    s.has_account = s.acct !== 0;
    s.has_amount = s.amount !== 0;
    s.isDebit = s.db !== 0;
    s.isCredit = s.cr !== 0;
    s.blank = (!s.has_account && !s.isDebit && !s.isCredit && !s.has_amount);
    s.incomplete = s.has_account && !s.isDebit && !s.isCredit && !s.has_amount;
    if (s.is_deleted){s.incomplete=false}
    s.scratch = !s.has_account && (s.isDebit || s.isCredit) && s.has_amount;
    return s.valid = (s.has_account && (s.isCredit || s.isDebit || s.is_deleted)) || (s.blank) // || s.incomplete);
  };

  /*
   * decaffeinate suggestions:
   * DS102: Remove unnecessary code created because of implicit returns
   * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
   */
  set_split = function(s) {
    // there or 16 possible states for 4 attributes
    // 8 tests for account blank
    if (s.acct === 0) {
      // yyyy
      if ((s.db === 0)  && (s.cr === 0) && (s.amount === 0)) {
        this.set_state(s);
        return;
      }
      // yyyn
      if ((s.db === 0)  && (s.cr === 0) && (s.amount !== 0)) {
        this.clear_amt(s); 
        return;
      }
      // yyny
      if ((s.db === 0)  && (s.cr !== 0) && (s.amount === 0)) {
        this.set_cr_amount(s);
        return;
      }
      // yynn
      if ((s.db === 0)  && (s.cr !== 0) && (s.amount !== 0)) {
        this.set_cr_amount(s);
        return;
      }
      // ynyy
      if ((s.db !== 0)  && (s.cr === 0) && (s.amount === 0)) {
        this.set_db_amount(s);
        return;
      }
      // ynyn
      if ((s.db !== 0)  && (s.cr === 0) && (s.amount !== 0)) {
        this.set_db_amount(s);
        return;
      }
      // this won't do anything if acct is zero
      // ynny
      if ((s.db !== 0)  && (s.cr !== 0) && (s.amount === 0)) {
        this.set_dbcr_amount(s);
        return;
      }
      // ynnn
      if ((s.db !== 0)  && (s.cr !== 0) && (s.amount !== 0)) {
        this.set_dbcr_amount(s);
        return;
      }
    // 8 test for account present
    } else { 
      // nyyy
      if ((s.db === 0)  && (s.cr === 0) && (s.amount === 0)) {
        this.set_state(s);
        return;
      }
      // nyyn
      if ((s.db === 0)  && (s.cr === 0) && (s.amount !== 0)) {
        this.clear_amt(s);
        return;
      }
      // nyny
      if ((s.db === 0)  && (s.cr !== 0) && (s.amount === 0)) {
        this.set_cr_amount(s);
        return;
      }
      // nynn
      if ((s.db === 0)  && (s.cr !== 0) && (s.amount !== 0)) {
        this.set_cr_amount(s);
        return;
      }
      // nnyy
      if ((s.db !== 0)  && (s.cr === 0) && (s.amount === 0)) {
        this.set_db_amount(s);
        return;
      }
      // nnyn
      if ((s.db !== 0)  && (s.cr === 0) && (s.amount !== 0)) {
        this.set_db_amount(s);
        return;
      }
      // amount does not affect if both db and cr set
      // nnny
      if ((s.db !== 0)  && (s.cr !== 0) && (s.amount === 0)) {
        this.set_dbcr_amount(s);
        return;
      }
      // nnnn
      if ((s.db !== 0)  && (s.cr !== 0) && (s.amount !== 0)) {
        this.set_dbcr_amount(s);
        return;
      }
    }
    // Falling through was an error I had and fixed, but just in case
    alert(`Why did it end up here it? id ${s.sindex} ac ${(s.acct)} db ${(s.db)} cr ${(s.cr)} amt ${(s.amount)}`);
    return console.log(s);
  };

  addbits = s => // some code I found that does math calculation
    (s.replace(/\s/g, '').match(/[+\-]?([0-9\.]+)/g) || []).reduce((sum, value) => parseFloat(sum) + parseFloat(value));

}
