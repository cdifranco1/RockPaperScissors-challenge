const { expect } = require("chai");
const { ethers } = require("hardhat");
import { Game } from "../typechain-types";


interface MoveToIntMapping {
  Rock: number,
  Paper: number,
  Scissors: number
}

const MoveMap: MoveToIntMapping = {
  Rock: 0,
  Paper: 1, 
  Scissors: 2
}

describe("Game", function () {

  let game: Game;

  before(async function () {
    const GameContract = await ethers.getContractFactory("Game");
    game = await GameContract.deploy();
    await game.deployed();  
  })
  
  it("Should add players to the game", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const gameWager = 5 * (10 * 18);
    const addPlayer1Tx = await game.joinGame(gameWager)
    await addPlayer1Tx.wait();

    game = game.connect(addr1)
    const addPlayer2Tx = await game.joinGame(gameWager);
    await addPlayer2Tx.wait();

    expect(await game.getGameWager()).to.equal(gameWager);

    expect(await game.player1()).to.equal(owner.address);
    expect(await game.player2()).to.equal(addr1.address);
  });

  it("Should add a player's move", async function() {
    const player1Move = MoveMap.Rock;
    const player2Move = MoveMap.Scissors;

    const [owner, addr1] = await ethers.getSigners();

    await (await game.startGame()).wait()

    game = game.connect(owner)
    await (await game.addPlayerMove(player1Move)).wait()

    game = game.connect(addr1);
    await (await game.addPlayerMove(player2Move)).wait()
    
    expect(await game.getPlayerMove(owner.address)).to.equal(player1Move);
    expect(await game.getPlayerMove(addr1.address)).to.equal(player2Move);
  })

  it("Should update player scores after the round", async function() {
    const [owner, addr1] = await ethers.getSigners();
    const player1Score = await game.getPlayerScore(owner.address);
    const player2Score = await game.getPlayerScore(addr1.address);

    expect(player1Score).to.equal(1);
    expect(player2Score).to.equal(0);

    expect(await game.currentRound()).to.equal(1);
  })
  
});
