const Databank = artifacts.require('Databank')
const DailyPot = artifacts.require('DailyPot')
const MainProtocol = artifacts.require('Databank')

module.exports = async function (deployer) {
  await deployer.deploy(Databank)
  const dbi = await Databank.deployed()
  await deployer.deploy(MainProtocol, dbi.address)
  const mpi = await MainProtocol.deployed()
  await deployer.deploy(DailyPot, dbi.address, mpi.address)
}
