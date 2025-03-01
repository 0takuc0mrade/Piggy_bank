import {
  time,
  loadFixture,
} from '@nomicfoundation/hardhat-toolbox/network-helpers';
import hre, { ethers } from 'hardhat';
import { expect } from 'chai';

describe('PiggyBank and PiggyBankFactory Contract Tests', function () {
  async function deployContracts() {
    const [owner, user1] = await ethers.getSigners();
    const withdrawalTime = (await time.latest()) + 8 * 24 * 60 * 60;

    const usdt = await hre.ethers.getContractAt(
      'IERC20',
      '0xdAC17F958D2ee523a2206206994597C13D831ec7',
    );
    const usdc = await hre.ethers.getContractAt(
      'IERC20',
      '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
    );
    const dai = await hre.ethers.getContractAt(
      'IERC20',
      '0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6',
    );
    // Deploy PiggyBankFactory Contract
    const PiggyBankFactory = await ethers.getContractFactory(
      'PiggyBankFactory',
    );
    const piggyBankFactory = await PiggyBankFactory.deploy();

    return { piggyBankFactory, usdt, usdc, dai, owner, user1, withdrawalTime };
  }

  describe('Deployment', () => {
    it('Should create a PiggyBank through the factory', async function () {
      const { piggyBankFactory, owner, usdt, withdrawalTime } =
        await loadFixture(deployContracts);
      await expect(
        piggyBankFactory.createBank(
          withdrawalTime,
          usdt.target,
          'Vacation Savings',
        ),
      ).to.emit(piggyBankFactory, 'bankCreated');
    });
  });

  describe('Deposits', () => {
    it('Should allow deposits with USDT', async function () {
      const { piggyBankFactory, owner, usdt, withdrawalTime } =
        await loadFixture(deployContracts);
      await piggyBankFactory.createBank(
        withdrawalTime,
        usdt.target,
        'Vacation Savings',
      );
      const userBanks = await piggyBankFactory.getUserBanks(owner.address);
      const piggyBank = await ethers.getContractAt('PiggyBank', userBanks[0]);

      const depositAmount = ethers.parseEther('10');
      await usdt.connect(owner).approve(piggyBank.target, depositAmount);
      await expect(piggyBank.save(depositAmount)).to.emit(
        piggyBank,
        'deposited',
      );
    });
  });

  describe('Withdrawals', () => {
    it('Should not allow withdrawals before the withdrawal date', async function () {
      const { piggyBankFactory, owner, usdt, withdrawalTime } =
        await loadFixture(deployContracts);
      await piggyBankFactory.createBank(
        withdrawalTime,
        usdt.target,
        'Vacation Savings',
      );
      const userBanks = await piggyBankFactory.getUserBanks(owner.address);
      const piggyBank = await ethers.getContractAt('PiggyBank', userBanks[0]);
      await expect(piggyBank.withdrawal()).to.be.revertedWith('NOT YET TIME');
    });
  });

  describe('Finalization', () => {
    it('Should allow the manager to finalize the contract', async function () {
      const { piggyBankFactory, owner, usdt, withdrawalTime } =
        await loadFixture(deployContracts);
      await piggyBankFactory.createBank(
        withdrawalTime,
        usdt.target,
        'Vacation Savings',
      );
      const userBanks = await piggyBankFactory.getUserBanks(owner.address);
      const piggyBank = await ethers.getContractAt('PiggyBank', userBanks[0]);
      await piggyBank.finalized();
      expect(await piggyBank.isFinalized()).to.be.true;
    });
  });
});
