// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract MyContract {

    uint256 public value = 0;

    function increment() public{
        value += 1;
    }
    function decrement() public{
        require(value > 0,"Value cannot be less than 0");
        value -= 1;
    }
    function getCountValue() public view returns(uint256){
        return value;
    }
}