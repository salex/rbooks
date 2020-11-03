/*
New POS sales
total sales expected = total_net_sales + total_taxes + total_tips
total cred sales = credit sales - tips
item sales 
  total_net_sales + tax (1.17 for liquor, 1.1 for others) + total_tips



*/
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "disabled",'credit','cashOut','tips','revenueAmount','revenue',
  'net','expected','over_under','tax','price','quanity','salesDeposit','counted','cash','out','otherRevenue','otherSum']

  connect() {
    let currRevenue
    let salesRevenue
    if (this.hasTaxTarget) {
      this.disable()
      this.init()
    }
  }

  disable(){
    const dis = this.disabledTargets
    for (var i = 0;  i < dis.length; i++) {
      dis[i].disabled = true
    }
  }

  init(){
    var salesDeposit = Number(this.salesDepositTarget.value)
    if (salesDeposit > 0) {
      this.countedTarget.value = this.salesDepositTarget.value
      this.changed()
    }
  }

  enable(){
    const dis = this.disabledTargets
    for (var i = 0;  i < dis.length; i++) {
      dis[i].disabled = false
    }
  }

  changed(){
    if (this.salesRevenue == undefined) {
      this.getRevenue()
    }
    const credit = Number(this.creditTarget.value)
    const tips = Number(this.tipsTarget.value)
    const cash = this.salesRevenue - credit + tips
    const cashOut = Number(this.cashOutTarget.value)
    const counted = Number(this.countedTarget.value)
    const expected = cash - tips  - cashOut
    var salesDeposit = Number(this.salesDepositTarget.value)
    this.creditTarget.value = credit.toFixed(2)
    this.tipsTarget.value = tips.toFixed(2)
    this.cashTarget.value = cash.toFixed(2)
    this.outTarget.value = cashOut.toFixed(2)
    this.expectedTarget.value = expected.toFixed(2)
    this.countedTarget.value = counted.toFixed(2)
    this.salesDepositTarget.value = counted.toFixed(2)
    salesDeposit = Number(this.salesDepositTarget.value)
    this.over_underTarget.value = (counted - expected).toFixed(2)
    const valid = counted != 0 && (this.countedTarget.value == this.salesDepositTarget.value )
    if (valid) {
      this.enable()
    }else{
      this.disable()
    }
  }

  calculate(){
    this.getRevenue()
  }

  getRevenue(){
    let total = 0
    let tax = this.taxTargets
    let price = this.priceTargets
    let net = this.netTargets
    let amt = this.revenueAmountTargets
    let qty = this.quanityTargets
    var numbRevenue = tax.length
    this.currRevenue = []
    for (var i = 0;  i < numbRevenue; i++) {
      var obj = {}
      obj.index = i 
      obj.$tax = tax[i]
      obj.$net = net[i]
      obj.$amt = amt[i]
      obj.$qty = qty[i]
      obj.$price = price[i]
      if (net[i].value === '') {
        const tot = Number(amt[i].value)
        total += tot
        if (tot > 0) {
          obj.$amt.value = tot.toFixed(2)
        }
      }else{
        var ntax = Number(tax[i].value)
        var nnet = Number(net[i].value)
        var nqty = Number(qty[i].value)
        var namt = Number(amt[i].value)
        var nprice = Number(price[i].value)
        var x = nnet * (1 + ntax)
        var gross = (Math.round(x * 4) / 4)
        nqty = Math.round(gross / nprice) 
        obj.$qty.value = nqty
        total += gross
        obj.$amt.value = gross.toFixed(2)
      }
      this.currRevenue[i] = obj
    }
    this.revenueTarget.value = total.toFixed(2)
    this.salesRevenue = total
  }

  otherChange(){
    console.log('got an other change')
    var sum = 0
    let amts = this.otherRevenueTargets
    for (var i = 0;  i < amts.length; i++) {
      var value = Number(amts[i].value)
      if (value > 0) {
        sum += value
        amts[i].value = value.toFixed(2)
      }
    }
    this.otherSumTarget.value = sum.toFixed(2)
  }
}
