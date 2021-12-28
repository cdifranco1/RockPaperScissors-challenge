# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```


Game Flow:
1. Land on interface
2. Connect wallet
3. Join a game with an arbitrary wager amount
4. Wait until someone joins your game
5. When someone joins the game -- event is emitted. UI asks player to select a move. 
6. Player selects move
7. When both players have selected a move, new event is emitted and score is updated in UI. 
8. Repeat 6-7 until winner declared. 