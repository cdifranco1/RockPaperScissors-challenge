const hre = require('hardhat')

module.exports = async ({deployments, getNamedAccounts}) => {
  const {deploy} = deployments;
  const {deployer} = await getNamedAccounts();

  console.log(deployer)

  await deploy('Game', {
    from: deployer,
    log: true,
  })
}