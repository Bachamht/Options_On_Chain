// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";



contract OptionFactory {
    using Clones for address;
    address public owner;
    address public templete;
    address [] public optionAddress;

    error NotOwner(address user);
    error DeployFailed();

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

    function deployOption(uint256 _optionPrice, uint256 _exercisePrice, uint256 _optionAmount, uint256 _exerciseDateStart, uint256 _exerciseDateEnd, address _admin) payable public returns(address) {
        require(msg.value >= _optionAmount * 1 ether, "Need to lock up the ETH assets");
        address cloneOption = templete.clone();
        (bool success, bytes memory data) = cloneOption.call{ value : _optionAmount * 1 ether }(
            abi.encodeWithSignature("init(uint256,uint256,uint256,uint256,uint256,address)", _optionPrice, _exercisePrice, _optionAmount, _exerciseDateStart, _exerciseDateEnd, _admin)
        );
        if(!success) revert DeployFailed(); 
        optionAddress.push(cloneOption);
        return cloneOption;
    }

}
