// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";



contract Option is OwnableUpgradeable, ERC20Upgradeable {
    
    address private admin;
    uint256 private exerciseDateStart;
    uint256 private exerciseDateEnd;
    uint256 private optionPrice;
    uint256 private exercisePrice;
    uint256 private amount;
    uint256 private optionAmount;
    uint256 private numberSold;
    address public USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    error NotOwner(address user);
    error HaveSoldOut();
    error InsufficientPayment();
    error WrongDate();
    error transferFailed();

    modifier onlyAdmin{
        if(msg.sender != admin) revert NotOwner(msg.sender);
        _;
    } 

    modifier underLimit(uint256 buyAmount){
        if(numberSold + buyAmount > optionAmount) revert HaveSoldOut();
        _;
    }

    function init (uint256 _optionPrice, uint256 _exercisePrice, uint256 _optionAmount, uint256 _exerciseDateStart, uint256 _exerciseDateEnd) payable public initializer{
       require(msg.value > (_optionAmount * 1 ether), "Need to lock up the ETH assets");
        __ERC20_init("option", "option");
       optionPrice = _optionPrice;
       exercisePrice = _exercisePrice;
       optionAmount = _optionAmount;
       exerciseDateStart = _exerciseDateStart;
       exerciseDateEnd = _exerciseDateEnd;
    }

    function buyOption(uint buyAmount) payable public underLimit(buyAmount){
        if(msg.value < buyAmount * optionPrice) revert InsufficientPayment();
        _mint(msg.sender, buyAmount);
        numberSold += buyAmount;
    }

    function exerciseOption(uint opAmount) public {
        if(block.timestamp < exerciseDateStart) revert WrongDate();
        if(block.timestamp > exerciseDateEnd) revert WrongDate();
        uint256 value = opAmount * exercisePrice;
        IERC20(USDT).transferFrom(msg.sender, address(this), value);
        _burn(msg.sender, opAmount);
        (bool sent, bytes memory data) = msg.sender.call{value: (opAmount * 1 ether) }("");
        if(!sent) revert transferFailed();
    }


    function burnExpiredOptions() public onlyAdmin{
        if(block.timestamp < exerciseDateEnd)  revert WrongDate(); 
        (bool sent, bytes memory data) = msg.sender.call{value: address(this).balance}("");
        if(!sent) revert transferFailed();
    }

    function withdrawProfit(address usdtReceive) public onlyAdmin{
        uint256 value = IERC20(USDT).balanceOf(address(this));
        IERC20(USDT).transfer(usdtReceive, value);
    } 


}