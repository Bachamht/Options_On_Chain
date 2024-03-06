// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Option} from "../src/callOption.sol";
import {OptionFactory} from "../src/factory.sol";
import {USDTToken} from "../src/USDT.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";


contract OptionTest is Test {
   
    address admin = makeAddr("myadmin");
    address player1 = makeAddr("player1");
    address player2 = makeAddr("player2");
    address option;

    OptionFactory factory;
    USDTToken usd;
    Option op;
    
    function setUp() public {
        vm.startPrank(admin);
        factory = new OptionFactory();
        usd = new USDTToken();
        op = new Option();
        console.log("usdt address:", address(usd));
        deal(admin, 100000 ether);
        deal(player1, 100000 ether);
        deal(player2, 100000 ether);
        usd.mintTo(admin, 100000);
        usd.mintTo(player1, 100000);
        usd.mintTo(player2, 100000);
        factory.setTemplete(address(op));
        vm.stopPrank();
    }

    function test_useOption() public {
        deployOption1(0.1 ether, 3000, 100, block.timestamp, block.timestamp + 600, player1);
        vm.startPrank(player2);
        (bool sent, bytes memory data) = option.call{value: 5 ether}(
            abi.encodeWithSignature("buyOption(uint256)", 50)
        );
        usd.approve(option, 20 * 3000);
        console.log("before exercise",player2.balance);
        Option(option).exerciseOption(20, address(usd));
        console.log("after exercise", player2.balance);
        vm.stopPrank();

        vm.startPrank(player1);
        Option(option).withdrawProfit(player1, address(usd));
        console.log("usdt get:",  usd.balanceOf(player1));
        vm.stopPrank();
    }

    function test_burnExpiredOptions() public {
        deployOption2(0.1 ether, 3000, 100, block.timestamp, block.timestamp - 1, player1);
        vm.startPrank(player1);
        console.log("before burn", player2.balance);
        Option(option).burnExpiredOptions();
        console.log("after burn", player2.balance);
        vm.stopPrank();
    }

    function deployOption1(uint256 _optionPrice, uint256 _exercisePrice, uint256 _optionAmount, uint256 _exerciseDateStart, uint256 _exerciseDateEnd, address _admin) public {
        vm.startPrank(player1);
        (bool sent, bytes memory data) = address(factory).call{value: 100 ether}(
            abi.encodeWithSignature("deployOption(uint256,uint256,uint256,uint256,uint256,address)", _optionPrice,  _exercisePrice, _optionAmount, _exerciseDateStart, _exerciseDateEnd, _admin)
        );
        address optionAddr;
        assembly {
            optionAddr := mload(add(data, 32))
        }
        option = optionAddr;
        vm.stopPrank();
    }

    
    function deployOption2(uint256 _optionPrice, uint256 _exercisePrice, uint256 _optionAmount, uint256 _exerciseDateStart, uint256 _exerciseDateEnd, address _admin) public {
        vm.startPrank(player1);
        (bool sent, bytes memory data) = address(factory).call{value: 100 ether}(
            abi.encodeWithSignature("deployOption(uint256,uint256,uint256,uint256,uint256,address)", _optionPrice,  _exercisePrice, _optionAmount, _exerciseDateStart, _exerciseDateEnd, _admin)
        );
        address optionAddr;
        assembly {
            optionAddr := mload(add(data, 32))
        }
        option = optionAddr;
        console.log("option address:", option);
        vm.stopPrank();
    }

}
