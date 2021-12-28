//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./TestToken.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";
import "hardhat/console.sol";

enum Move {
    NoMove,
    Rock,
    Paper,
    Scissor
}

enum GameState {
    Uninitialized,
    Active,
    Completed
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

    uint public gameWager;

    address public player1;
    address public player2;

    uint public currentRound;

    GameState public gameState;

    mapping(address => Move[]) playerMoves;
    mapping(address => uint16) playerScores;

    event MovesSelected(Move player1Move, Move player2Move, uint8 round);
    event RoundScored(uint16 player1Score, uint16 player2Score);

    event GameWon(address indexed winner);
    
    event GameWinner(address winner);

    function getGameWager() public view returns(uint) {
        return gameWager;
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

    function addPlayerMove(Move move) public {
        require(gameState == GameState.Active, "Game is not ready to accept moves");
        playerMoves[msg.sender].push(move);

        Move player1Move = playerMoves[player1][currentRound]; 
        Move player2Move = playerMoves[player2][currentRound];
        console.log("Player 1 move: ", player1,  uint(player1Move));
        console.log("Player 2 move: ", player2, uint(player2Move));
        console.log("Current Round: ", currentRound);
        if (player1Move != Move.NoMove && player2Move != Move.NoMove) {
            address roundWinner = selectRoundWinner(player1Move, player2Move);
            if (roundWinner != address(0)) {
                playerScores[roundWinner] += 1;
                if (isGameWinner(roundWinner)) {
                    emit GameWon(roundWinner);
                    gameState = GameState.Completed;
                }
            }
            currentRound += 1;
        }
    }

    function startGame() external {
        require(player1 != address(0) && player2 != address(0), "Players have not been assigned yet");
        gameState = GameState.Active;
    }

    function getPlayerMove(address _player) public view returns(Move) {
        uint latestRound = Math.max(0, currentRound - 1);

        console.log("Latest round", latestRound);
        console.log("Current round", currentRound);
        return playerMoves[_player][latestRound];
    }

    function selectRoundWinner(Move _player1Move, Move _player2Move) internal view returns(address) {
        if (_player1Move > _player2Move) {
            return player1;
        } else if (_player2Move > _player1Move) {
            return player2;
        } else {
            return address(0);
        }
    }

    function isGameWinner(address _roundWinner) internal view returns(bool) {
        uint16 roundWinnerScore = playerScores[_roundWinner];
        address challenger;

        if (_roundWinner == player1) {
            challenger = player2;
        } else {
            challenger == player1;
        }

        if (roundWinnerScore >= 2 && roundWinnerScore - playerScores[challenger] >= 1) {
            return true;
        }

        return false;
    }

}

