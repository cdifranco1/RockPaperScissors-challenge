const { expect } = require("chai");
const { ethers } = require("hardhat");
import { Game } from "../typechain-types";

describe("Game", function () {

  let game: Game;

  before(async function () {
    const GameContract = await ethers.getContractFactory("Game");
    game = await GameContract.deploy();
    await game.deployed();  
  })
  
  it("Should add players to the game", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    console.log("RUNNING TEST");

    const gameWager = 5 * (10 * 18);
    const addPlayer1Tx = await game.joinGame(gameWager)

    game.connect()
    const addPlayer2Tx = await game.joinGame(gameWager);

    await addPlayer1Tx.wait();
    await addPlayer2Tx.wait();
    expect(await game.getGameWager()).to.equal(gameWager);

    const player1 = await game.player1();
    const player2 = await game.player2();
    console.log(player1);
    console.log(player2);

  });

  it("Should add a player's move", async function() {
    const player1Move = 1;
    const player2Move = 2;

    const [owner, addr1, addr2] = await ethers.getSigners();

    await (await game.startGame()).wait()

    await (await game.addPlayerMove(player1Move)).wait()

    game.connect(addr1);
    await (await game.addPlayerMove(player2Move)).wait()
    
    expect(await game.getPlayerMove(owner.address)).to.equal(player1Move);
    expect(await game.getPlayerMove(addr1.address)).to.equal(player2Move);
  })
  
});
