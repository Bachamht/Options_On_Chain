// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Option} from "../src/callOption.sol";
import {OptionFactory} from "../src/factory.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract OptionTest is Test {
   
    address admin = makeAddr("myadmin");
    address player1 = makeAddr("player1");
    address player2 = makeAddr("player2");
    address public USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    OptionFactory factory;
    address option;
    
    function setUp() public {
        vm.startPrank(admin);
        factory = new OptionFactory();
        deal(admin, 100000 ether);
        deal(player1, 100000 ether);
        deal(player2, 100000 ether);
        deal(address(USDT), admin, 1 ether); 
        deal(address(USDT), player1, 1 ether); 
        deal(address(USDT), player2, 1 ether); 
        vm.stopPrank();
    }

    function test_useOption() public {
        deployOption1();
        vm.startPrank(player2);
        Option(option).buyOption(50);
        ERC20(USDT).approve(option, 20 * 3000);
        console.log("before exercise",player2.balance);
        Option(option).exerciseOption(20);
        console.log("after exercise", player2.balance);
        vm.stopPrank();

        vm.startPrank(player1);
        Option(option).withdrawProfit(player1);
        console.log("usdt get:",  ERC20(USDT).balanceOf(player1));
        vm.stopPrank();


    }

    function test_burnExpiredOptions() public {
        vm.startPrank(player1);
        deployOption2();
        console.log("before burn", player2.balance);
        Option(option).burnExpiredOptions();
        console.log("after burn", player2.balance);
        vm.stopPrank();

    }

    function deployOption1() public {
        vm.startPrank(player1);
        option = factory.deployOption();
        bytes memory callData = abi.encodeWithSignature("init(uint256, uint256, uint256, uint256, uint256)", 0.1 ether,  3000, 100, block.timestamp, block.timestamp + 60000);
        (bool sent, bytes memory data) = option.call{value: 100 ether}(callData);
        vm.stopPrank();
    }

    
    function deployOption2() public {
        vm.startPrank(player1);
        option = factory.deployOption();
        bytes memory callData = abi.encodeWithSignature("init(uint256, uint256, uint256, uint256, uint256)", 0.1 ether,  3000, 100, block.timestamp, block.timestamp);
        (bool sent, bytes memory data) = option.call{value: 100 ether}(callData);
        vm.stopPrank();
    }

}
