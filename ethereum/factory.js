import web3 from './web3';
import CampaignFactory from './build/CampaignFactory.json';
import { deployedContractAddress } from '../address';

const instance = new web3.eth.Contract(
    JSON.parse(CampaignFactory.interface), deployedContractAddress);

export default instance;