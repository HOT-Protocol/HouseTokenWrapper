const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SpellRegist", function () {
    let spr
    let owner, account1, account2, account3, account4

     beforeEach(async function(){
         // Contracts are deployed using the first signer/account by default
         const SpellRegist = await ethers.getContractFactory("SpellRegist");
         [owner, account1, account2, account3, account4] = await ethers.getSigners();
         //console.log(account1.address, account2.address, account3.address, account4.address);
         spr = await SpellRegist.deploy([account1.address, account2.address, account3.address, account4.address]);
     });

    describe("Deployment", function () {
        it("should be right owner", async function () {
             expect(await spr.owner()).to.equal(owner.address);
        });
    });

    describe("Auth ", function () {
        it("should accounts be auth", async function () {
            expect(await spr.signers(account1.address)).to.equal(true);
            expect(await spr.signers(account2.address)).to.equal(true);
            expect(await spr.signers(account3.address)).to.equal(true);
            expect(await spr.signers(account4.address)).to.equal(true);
        });

        it("deny", async function(){
            await spr.deny(account4.address);
            expect(await spr.signers(account4.address)).to.equal(false);
        });
    });
});