// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "../src/PremiumSubscriptionNFT.sol";

contract PremiumSubscriptionNftScript is Script {
    function setUp() public {}

    function run() public {
      
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address account = vm.addr(privateKey);

        console.log("Account", account);

        vm.startBroadcast(privateKey);

        new PremiumSubscriptionNFT();

        vm.stopBroadcast();
    }
}
