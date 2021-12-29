const { expect } = require("chai");
const { ethers } = require("hardhat");
import { ContractFactory, ContractReceipt, ContractTransaction } from "ethers";
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
  // let GameContract: ContractFactory;

  const defaultWager = 5 * (10 * 18);

  before(async function () {
    const GameContract = await ethers.getContractFactory("Game");
    game = await GameContract.deploy();
    await game.deployed();  
  })
  
  it("Should add players to the game", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();

    
    const addPlayer1Tx = await game.joinGame(defaultWager)
    await addPlayer1Tx.wait();

    game = game.connect(addr1)
    const addPlayer2Tx = await game.joinGame(defaultWager);
    await addPlayer2Tx.wait();

    expect(await game.getGameWager()).to.equal(defaultWager);

    expect(await game.player1()).to.equal(owner.address);
    expect(await game.player2()).to.equal(addr1.address);
  });

  // need to update move functionality to check that player hasn't already moved this round
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

  it("Should update player scores and current round after moves selected", async function() {
    const [owner, addr1] = await ethers.getSigners();
    const player1Score = await game.getPlayerScore(owner.address);
    const player2Score = await game.getPlayerScore(addr1.address);

    expect(player1Score).to.equal(1);
    expect(player2Score).to.equal(0);

    expect(await game.currentRound()).to.equal(1);
  })

  it("Should emit GameWon event after winning round", async function() {
    const GameFactory = await ethers.getContractFactory("Game");
    let game: Game = await GameFactory.deploy();
    const [player1, player2] = await ethers.getSigners();

    await (await game.joinGame(defaultWager)).wait();

    game = game.connect(player2);
    await (await game.joinGame(defaultWager)).wait()

    await game.startGame();

    let moveTxReceipt: ContractReceipt | undefined = undefined;

    for (let i = 0; i < 4; i ++) {
      const player = i % 2 ? player1 : player2
      const move = i % 2 ? MoveMap.Rock : MoveMap.Scissors

      game = game.connect(player);

      const moveTx: ContractTransaction = await game.addPlayerMove(move)

      moveTxReceipt = await (moveTx.wait())
    }

    if (moveTxReceipt != undefined){
      console.log(moveTxReceipt.events)
      // expect(moveTxReceipt.events).to.equal(player1)
    }
    // expect(moveTxReceipt.events)
    // await new Promise(res => setTimeout(() => res(null), 5000));
    // game.on("GameWon", () => {
    //   console.log("GameWon Event emitted");
    // })

    console.log(await game.getPlayerScore(player1.address))
    console.log(await game.getPlayerScore(player2.address))
  })

  
});
