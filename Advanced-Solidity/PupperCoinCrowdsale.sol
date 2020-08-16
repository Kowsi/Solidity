pragma solidity ^0.5.0;

import "./PupperCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

/* This PupperCoinCrowdsale contract will manage the entire process, allowing users to send ETH and get back PUP (PupperCoin).
This contract will mint the tokens automatically and distribute them to buyers in one transaction.
*/

// Inherit the Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, RefundablePostDeliveryCrowdsalecontracts
contract PupperCoinCrowdsale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, RefundablePostDeliveryCrowdsale{

    uint fakenow;
    
    constructor (
        uint rate, // rate in TKNbits
        //string memory name, 
        //string memory symbol,
        address payable wallet, 
        PupperCoin token,
        uint goal,
        uint open,
        uint close
        
    )
        Crowdsale(rate, wallet, token)
        CappedCrowdsale(goal)
        //TimedCrowdsale(open = now, close = now + 1 minutes) in this case
        //TimedCrowdsale(open = now, close = now + 24 weeks) in the original question
        //TimedCrowdsale(fakenow, now + 1 minutes)
        TimedCrowdsale(open, close)
        RefundableCrowdsale(goal)
        public
    {

    }
}

contract PupperCoinSaleDeployer {

    address public token_sale_address;
    address public token_address;
    
    uint fakenow = now;
    uint rate = 1;
    
    constructor(
        string memory name,
        string memory symbol,
        address payable wallet, // this address will receive all Ether raised by the sale
        uint goal
    )
        public
    {
        // @TODO: create the PupperCoin and keep its address handy
        PupperCoin pupper_token = new PupperCoin(name, symbol, 0);
        token_address = address(pupper_token);
        
        // The PupperCoinSale and tell it about the token, set the goal, and set the open and close times to now and now + 24 weeks.
        PupperCoinCrowdsale pupper_sale = new PupperCoinCrowdsale(rate, wallet, pupper_token, goal, fakenow, now + 5 minutes);
        //PupperCoinCrowdsale pupper_sale = new PupperCoinCrowdsale(1, wallet, pupper_token, goal, now, now + 24 weeks);
        token_sale_address = address (pupper_sale);
        
        // make the PupperCoinSale contract a minter, then have the PupperCoinSaleDeployer renounce its minter role
        pupper_token.addMinter(token_sale_address);
        pupper_token.renounceMinter();
    }
}
