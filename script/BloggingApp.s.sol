// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import {BloggingApp} from "../src/BloggingApp.sol";

contract BloggingAppScript is Script {
    function setUp() public {}

    function run() public {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);

        new BloggingApp();

        vm.stopBroadcast();
    }
}
