const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
// const { interface, bytecode } = require('./compile');
const compiledFactory = require('./build/CampaignFactory.json');
import { walletMnemonic } from '../address';

const provider = new HDWalletProvider(
    walletMnemonic,
    'https://rinkeby.infura.io/PEUwSicCwZjy3dofeaUl'
);

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();

    console.log('Attempting to deploy from account: ', accounts[0]);

    const result = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
        .deploy({
            data: compiledFactory.bytecode
        })
        .send({
            from: accounts[0],
            gas: '1000000'
        });
    console.log('Contract Deployed to: ', result.options.address);
}

deploy();



