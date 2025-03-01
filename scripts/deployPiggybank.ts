import hre from 'hardhat';

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log(`Deploying PiggyBankFactory with account: ${deployer.address}`);

  // Deploy PiggyBankFactory Contract
  const PiggyBankFactory = await hre.ethers.getContractFactory(
    'PiggyBankFactory',
  );
  const piggyBankFactory = await PiggyBankFactory.deploy();
  await piggyBankFactory.waitForDeployment();

  console.log(
    `PiggyBankFactory deployed at: ${await piggyBankFactory.getAddress()}`,
  );
}

// Execute deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
