//import { AssertionError } from "assert";

var ERC721MintableComplete = artifacts.require('PlatinumERC721Token');

contract('TestERC721Mintable', accounts => {

    const account_one = accounts[0]; // owns the contract
    const account_two = accounts[1]; // firstly owns the tokens
    const account_three = accounts[2]; // will receive tokens

    const tokenId1 = 11;
    const tokenId2 = 22;

    describe('match erc721 spec', function () {
        beforeEach(async function () { 
            this.contract = await ERC721MintableComplete.new({from: account_one});

            try{
                // TODO: mint multiple tokens
                await this.contract.mint(account_two,tokenId1);
                await this.contract.mint(account_two,tokenId2);
            } catch(e){
                console.log("Error while minting " + e);
            }


        })

        it('should return total supply', async function () { 
            try{
                let totalSupply = await this.contract.totalSupply();
                console.log("Total Supply: " + totalSupply);
                assert.equal(totalSupply>=0,true,"Couldn´t retrieved total supply");
            } catch(e){
                console.log("Error while retrieving total suppply " + e);
            }
        })

        it('should get token balance', async function () { 
            try{
                let balance = await this.contract.balanceOf(account_two);
                console.log("Balance of " + account_two + " is: " + balance);
            }catch(e){
                console.log("Error while retrieving balace " + e);
            }
        })

        // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
        it('should return token uri', async function () { 
            try{
                let tokenURI = await this.contract.tokenURI(tokenId1);
                console.log("tokenURI of " + tokenId1 + " is: " + tokenURI);
            }catch(e){
                console.log("Error while retrieving tokenURI " + e);
            }
        })

        it('should transfer token from one owner to another', async function () { 
            try{
                // The transfer operation executed by the token owner:
                await this.contract.transferFrom(account_two,account_three,tokenId2,{from: account_two});
                // Checks new owner
                let newOwner = await this.contract.ownerOf(tokenId2);
                console.log("Owner of " + tokenId2 + " is now: " + newOwner);
                assert.equal(newOwner,account_three,"Token transfer didn´t succeed");
            }catch(e){
                console.log("Error while transferring tokens " + e);
            }
        })
    });

    describe('have ownership properties', function () {
        beforeEach(async function () { 
            this.contract = await ERC721MintableComplete.new({from: account_one});
        })

        it('should fail when minting when address is not contract owner', async function () { 
            let fail = false;
            try{
                await this.contract.mint(account_two,tokenId1,{from:account_three});
            }catch(e){
                fail = true;
                //console.log("Error while minting as not owner " + e);
            }
            assert.equal(fail,true,"Minting is not restricted to owner");
        })

        it('should return contract owner', async function () { 
            try{
                let contractOwner = await this.contract.owner.call({from: account_one});
                console.log("Contract owner: " + contractOwner);
                assert.equal(contractOwner,account_one,"Contract owner is not account_one");
            }catch(e){
                console.log("Error while retrieving contract owner " + e);
            }
        })

    });
})