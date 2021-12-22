//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";


contract TestToken is ERC20 {
    address player1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address player2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    constructor () ERC20("TestToken", "TST") {
        console.log("Deploying contract to address: ", address(this));
        _mint(msg.sender, 1000 * (10 ** 18));
        _mint(player1, 1000 * (10 ** 18));
        _mint(player2, 1000 * (10 ** 18));
    }
}