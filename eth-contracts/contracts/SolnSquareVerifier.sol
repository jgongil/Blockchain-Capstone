pragma solidity >=0.4.21 <0.6.0;

// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>

import './Verifier.sol';
import './ERC721Mintable.sol';

// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class

/* DESCRIPTION:
This contract calls the zokrates solidity contract (verifier). The verifier will be used to verify the proof
generated through zokrates.
A user will be able to mint a token only if they own it (verification through zok)

The "Soultion" concept is a way to ensure that the verification process is unique, so a user cannot mint
multiple tokens reusing the same verification process.
*/

contract SolnSquareVerifier is PlatinumERC721Token, Verifier {

// TODO define a solutions struct that can hold an index & an address

/* We ensure that only one verification is used at a time:
-> each verification is unique and cannot be reused. Somebody trying to mint multiple tokens */
    struct Solution {
                        bytes32 index;
                        address addr;
                        bool isUsed;
                    }

// TODO define an array of the above struct
    Solution[] Solutions;

// TODO define a mapping to store unique solutions submitted
    mapping(bytes32 => Solution) private solutionsSubmitted;

// TODO Create an event to emit when a solution is added
    event solutionAdded(bytes32 index, address addr);

// UTILITY Functions:

    // Checks if the solution exists in the contract (regardless it was used or not)
    function solutionExists (
                            uint[2] memory a,
                            uint[2][2] memory b,
                            uint[2] memory c,
                            uint[2] memory input
                        )
                        view
                        internal
                        returns(bool)
    {
        bytes32 inputIndex = getSolutionKey(a,b,c,input);
        return (solutionsSubmitted[inputIndex].index == inputIndex);
    }

   // Checks if a solution is valid -> It EXISTS in the contract && wasn´t USED && is assigned to the "to" ADDRESS
    function solutionIsValid (
                            uint[2] memory a,
                            uint[2][2] memory b,
                            uint[2] memory c,
                            uint[2] memory input,
                            address to
                        )
                        view
                        internal
                        returns(bool)
    {
        require(solutionExists(a,b,c,input), "Solution doesn´t exist");
        bytes32 inputIndex = getSolutionKey(a,b,c,input);
        
        return (!solutionsSubmitted[inputIndex].isUsed && solutionsSubmitted[inputIndex].addr == to);
    }

    // Hashes proof parameters
    function getSolutionKey
                        (
                        uint[2] memory a,
                        uint[2][2] memory b,
                        uint[2] memory c,
                        uint[2] memory input
                        )
                        pure
                        internal
                        returns(bytes32)
    {
        return keccak256(abi.encodePacked(a, b, c,input)); // The parameters must be in the same order to obtain the same hash.
    }

// TODO Create a function to add the solutions to the array and emit the event
    // Adds the solution to the contract, after verification and assigns it to the caller
    function addSolution (
                        uint[2] memory a,
                        uint[2][2] memory b,
                        uint[2] memory c,
                        uint[2] memory input
                        )
                        public
    {
        require(!solutionExists(a,b,c,input), "This solution already exists");
        require(super.verifyTx(a, b, c, input), "Solution verification failed");
        address addr = msg.sender;
        bytes32 index = getSolutionKey(a,b,c,input); // Generates a hash for the parameters used for the proof
        solutionsSubmitted[index] = Solution ({
                                                index: index,
                                                addr: addr,
                                                isUsed: false
                                            });
        Solutions.push(solutionsSubmitted[index]);
        emit solutionAdded(index, addr);
    }

 

// TODO Create a function to mint new NFT only after the solution has been verified
//  - make sure the solution is unique (has not been used before)
//  - make sure you handle metadata as well as tokenSuplly
    function secureMint(
                    address to,
                    uint256 tokenId,
                    uint[2] memory a,
                    uint[2][2] memory b,
                    uint[2] memory c,
                    uint[2] memory input
                )
                public
                returns(bool)
    {
        require(solutionIsValid(a, b, c, input, to), "The solution provided is not valid or was already used");
        bytes32 inputIndex = getSolutionKey(a,b,c,input);
        bool mintResult = super.mint(to, tokenId);
        solutionsSubmitted[inputIndex].isUsed = true;
        return mintResult;
    }
}













  


























