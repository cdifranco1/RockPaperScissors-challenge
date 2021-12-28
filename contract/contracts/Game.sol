//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./TestToken.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";
import "hardhat/console.sol";

enum Move {
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
    mapping(address => uint16) public playerScores;

    event MovesSelected(Move player1Move, Move player2Move, uint8 round);
    event RoundScored(uint16 player1Score, uint16 player2Score);

    event GameWon(address indexed winner);
    
    event GameWinner(address winner);

    function getGameWager() public view returns(uint) {
        return gameWager;
    }

    function joinGame(uint _wager) public {
        console.log("%s is joining game", msg.sender);
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
        address otherPlayer = getOtherPlayer(msg.sender);

        if (playerMoves[msg.sender].length == currentRound + 1 && playerMoves[otherPlayer].length == currentRound + 1) {
            Move player1Move = playerMoves[player1][currentRound]; 
            Move player2Move = playerMoves[player2][currentRound];
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


    function getOtherPlayer(address currentPlayer) internal view returns(address) {
        if (currentPlayer == player1) {
            return player2;
        } else if (currentPlayer == player2) {
            return player1;
        } else {
            return address(0);
        }
    }

    function startGame() external {
        require(player1 != address(0) && player2 != address(0), "Players have not been assigned yet");
        gameState = GameState.Active;
    }

    function getPlayerMove(address _player) public view returns(Move) {
        uint latestRound;

        if (currentRound > 0) {
            latestRound = currentRound - 1;
        } else {
            latestRound == 0;
        }

        return playerMoves[_player][latestRound];
    }

    function getPlayerScore(address _player) public view returns(uint16) {
        return playerScores[_player];
    }

    function selectRoundWinner(Move _player1Move, Move _player2Move) internal view returns(address) {
        if (_player1Move == Move.Rock) {
            if (_player2Move == Move.Rock) {
                return address(0);
            } else if (_player2Move == Move.Paper) {
                return player2;
            } else if (_player2Move == Move.Scissor) {
                return player1;
            }
        } else if (_player1Move == Move.Paper) {
            if (_player2Move == Move.Paper) {
                return address(0);
            } else if (_player2Move == Move.Scissor) {
                return player2;
            } else if (_player2Move == Move.Rock) {
                return player1;
            }
        } else if (_player1Move == Move.Scissor) {
            if (_player2Move == Move.Scissor) {
                return address(0);
            } else if (_player2Move == Move.Rock) {
                return player2;
            } else if (_player2Move == Move.Paper) {
                return player1;
            }
        }

        return address(0);
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

