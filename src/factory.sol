// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";



contract OptionFactory {
    using Clones for address;
    address public owner;
    address public templete;
    address [] public optionAddress;

    error NotOwner(address user);

    modifier onlyOwner {
        if(msg.sender != owner) revert NotOwner(msg.sender);
        _;
    } 

    constructor() {
        owner = msg.sender;
    }

    function setTemplete(address templeteAddress) public onlyOwner {
        templete = templeteAddress;
    }

    function deployOption() public returns(address) {
        address cloneOption = templete.clone();
        optionAddress.push(cloneOption);
        return cloneOption;
    }

 


}
