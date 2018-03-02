const solc = require('solc')
const Web3 = require('web3')
const fs = require('fs')

const web3 = new Web3(Web3.givenProvider || 'http://localhost:7545/' ) //ganache

let input = {
	'Owner.sol': fs.readFileSync('contracts/Owner.sol','utf8'),
	'EIP20Interface.sol' : fs.readFileSync('contracts/EIP20Interface.sol','utf8'),
	// 'TradeInterface.sol': fs.readFileSync('contracts/TradeInterface.sol','utf8'),
	'TokenTrade.sol': fs.readFileSync('contracts/TokenTrade.sol','utf8')
}

// let source = fs.readFileSync('contracts/TokenTrade.sol','utf8')

let compiled = solc.compile({sources:input},1)

let bytecode = compiled.contracts['TokenTrade.sol:TokenTrade'].bytecode
let abi = compiled.contracts['TokenTrade.sol:TokenTrade'].interface

// console.log(bytecode,abi)

// Init Contract
let Token = new web3.eth.Contract(JSON.parse(abi)) //always init with abi, others are optional and can be set (depending on what you need)
Token.options.from = '0x627306090abaB3A6e1400e9345bC60c78a8BEf57'
Token.options.address = '0x8cdaf0cd259887258bc13a92c0a6da92698644c0' //if you're using an existing contact
Token.options.gasPrice = 1 //meh
// Token.options.gas = 855889 //get this from estimateGas
// Token.options.data = bytecode //if you'res deploying 

Token.deploy({
	arguments: [10000,0,5,"KanKoin","KKN"]
})	
.estimateGas((err,gas)=>{console.log(gas)})

// Deploy Contract with gas value
Token.deploy({
	arguments: [10000,0,5,"KanKoin","KKN"]
})
.send()
.then((newContractInstance)=>{console.log(newContractInstance.options.address)})

// Estimate Gas of contract transaction [note: will automatically estimate gas if you call contract, and use]
Token.transfer('0xf17f52151EbEF6C7334FAD080c5704D77216b732',80)
.estimateGas()
.then((gasAmount)=>{console.log(gasAmount)})
.catch((error)=>{console.log(error)})

// Call contract with 'send' if you modify state
Token.methods.acceptOwnership().send()
.then((res)=>{console.log(res)})
.catch((error)=>{console.log(error)})

// else, just call with 'call' if you aren't modifying state/view
Token.methods.transfer('0xf17f52151EbEF6C7334FAD080c5704D77216b732',80).send()
.then((res)=>{console.log(res)})
.catch((error)=>{console.log(error)})

Token.methods.balanceOf('0x627306090abaB3A6e1400e9345bC60c78a8BEf57').call()
.then((res)=>{console.log(res)})
.catch((error)=>{console.log(error)})

//send eth to the contract for the token
web3.eth.sendTransaction({
	from: '0xf17f52151EbEF6C7334FAD080c5704D77216b732',
	to: '0x8cdaf0cd259887258bc13a92c0a6da92698644c0',
	value: web3.utils.toWei('3', 'ether')
}).then(receipt=>{
	console.log(receipt)
})

//sends eth to owner account
Token.methods.withdraw(10).send()
.then((res)=>{console.log(res)})
.catch((error)=>{console.log(error)})