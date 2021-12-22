const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Game", function () {
  it("Should add a player to the game", async function () {
    const Game = await ethers.getContractFactory("Game");
    const game = await Game.deploy();
    await game.deployed();

    const gameWager = 5 * (10 * 18);
    const addPlayerTx = await game.joinGame(gameWager)

    await addPlayerTx.wait()
    expect(await game.getWager()).to.equal(gameWager);
    expect(await game.player1).to.equal()
  });

  it("Should ")
});
