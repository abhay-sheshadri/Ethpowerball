# Ethpowerball
This is a smart contract for powerball written in solidity.

Players can buy tickets.  Every 500 blocks since the creation of the contract, the owner of the contract can initiate the drawing.  Six
balls are chosen using the hash of the previous block.  Winners can them claim their prize using the id of their ticket, which is the 
ticket's index in the array.  Upon validation, the player will recieve his/her prize.

Matching white ballsgives 0.01 ether per ball
Matching the red ball gives 0.01 ether
Users who match all six balls will get the jackpot prize instead

The contract is on the Ropsten test network
Contract Address (Proof of Concept): 0xbc983c2fb407cdbc94d74041a9cda63645370280
Etherscan: https://ropsten.etherscan.io/address/0xbc983c2fb407cdbc94d74041a9cda63645370280

