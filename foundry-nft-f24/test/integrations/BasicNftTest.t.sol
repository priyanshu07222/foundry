// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployBasicNft} from "script/DeployBasicNft.s.sol";
import {BasicNft} from "src/BasicNft.sol";

contract BasicNftTest is Test {
    DeployBasicNft public deployer;
    BasicNft public basicNft;
    address USER = makeAddr("User");
    string public constant PUG =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    string public constant NFT_NAME = "Doggie";
    string public constant NFT_SYMBOL = "Dog";

    function setUp() public {
        deployer = new DeployBasicNft();
        basicNft = deployer.run();
    }

    function testInitializedCorrectly() public view {
        assert(
            keccak256(abi.encodePacked(basicNft.name())) ==
                keccak256(abi.encodePacked(NFT_NAME))
        );
        assert(
            keccak256(abi.encodePacked(basicNft.symbol())) ==
                keccak256(abi.encodePacked(NFT_SYMBOL))
        );
    }

    function testCanzMintAndHaveABalance() public {
        vm.prank(USER);
        basicNft.mintNft(PUG);

        assert(basicNft.balanceOf(USER) == 1);
        assert(
            keccak256(abi.encodePacked(PUG)) ==
                keccak256(abi.encodePacked(basicNft.tokenURI(0)))
        );
    }
}
