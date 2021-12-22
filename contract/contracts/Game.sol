//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./TestToken.sol";
import "hardhat/console.sol";

enum PlayerMove {
    NoMove,
    Rock,
    Paper,
    Scissor
}

// interface COMP {
//   function approve(address spender, uint rawAmount) external returns (bool);
//   function balanceOf(address account) external view returns (uint);
//   function transferFrom(address src, address dst, uint rawAmount) external returns (bool);
// }

interface TST {
    function balanceOf(address account) external view returns (uint);
    function transferFrom(address src, address dst, uint rawAmount) external returns (bool);
}


contract Game {

    uint gameWager;

    address player1;
    address player2;

    mapping(address => PlayerMove[]) playerMoves;

    modifier isInGame(address _player) {
        require(player1 == _player || player2 == _player, "Player is not in game");
        _;
    }

    function joinGame(uint _wager) public {
        if (player1 == address(0)) {
            player1 = msg.sender;
            gameWager = _wager;
        } else if (player2 == address(0)) {
            player2 = msg.sender;
        } else {
            console.log("Game is full");
        }
    }


    function addPlayerMove(PlayerMove move) public {
        playerMoves[msg.sender].push(move);
    }

    

}

