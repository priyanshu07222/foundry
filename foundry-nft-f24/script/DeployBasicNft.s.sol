// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {BasicNft} from "src/BasicNft.sol";
import {console} from "forge-std/Test.sol";

contract DeployBasicNft is Script {
    function run() external returns (BasicNft) {
        vm.startBroadcast();
        BasicNft basicNft = new BasicNft();
        // string memory name = basicNft.name;
        // console.log("name fo %s", name);
        vm.stopBroadcast();
        return basicNft;
    }

    // function getname() public {
    //     string memory name = basicNft.name;
    //     console.log("name fo %s", name);
    // }
}
