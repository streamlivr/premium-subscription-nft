// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PremiumSubscriptionNFT is ERC1155, Ownable {
    uint256 private _tokenIdCounter;

    struct Subscription {
        uint256 startDate;
        uint256 endDate;
        bool active;
    }

    mapping(uint256 => Subscription) private _subscriptions;
    mapping(uint256 => bool) private _tokenExists;
    mapping(uint256 => string) private _tokenURIs;

    uint256 public subscriptionDuration = 30 days;
    uint256 public subscriptionPrice = 0.0001 ether;

    constructor() ERC1155("streamLivr") Ownable(msg.sender) {}

    // Function to subscribe
    function subscribe(string memory _uri) public payable {
        require(msg.value == subscriptionPrice, "Incorrect ETH amount sent");

        uint256 tokenId = _tokenIdCounter;
        _mint(msg.sender, tokenId, 1, "");
        _tokenIdCounter++;

        uint256 startDate = block.timestamp;
        uint256 endDate = startDate + subscriptionDuration;

        _subscriptions[tokenId] = Subscription(startDate, endDate, true);
        _tokenExists[tokenId] = true;
        _tokenURIs[tokenId] = _uri;

        _setURI(tokenId, _uri);
    }

    // Function to check if a subscription is active
    function isSubscriptionActive(uint256 tokenId) public view returns (bool) {
        require(_exists(tokenId), "Subscription does not exist");
        Subscription memory subscription = _subscriptions[tokenId];
        return block.timestamp <= subscription.endDate;
    }

    // Function to renew subscription
    function renewSubscription(uint256 tokenId) public payable {
        require(balanceOf(msg.sender, tokenId) > 0, "You do not own this subscription");
        require(!isSubscriptionActive(tokenId), "Subscription is still active");
        require(msg.value == subscriptionPrice, "Incorrect ETH amount sent");

        uint256 newStartDate = block.timestamp;
        uint256 newEndDate = newStartDate + subscriptionDuration;

        _subscriptions[tokenId] = Subscription(newStartDate, newEndDate, true);
    }

    // Function to update the subscription price
    function updateSubscriptionPrice(uint256 newPrice) public onlyOwner {
        subscriptionPrice = newPrice;
    }

    // Function to withdraw collected funds
    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // Internal function to check if a token exists
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenExists[tokenId];
    }

    // Internal function to set token URI
    function _setURI(uint256 tokenId, string memory _uri) internal {
        require(_exists(tokenId), "URI set of nonexistent token");
        _tokenURIs[tokenId] = _uri;
    }

    // Override uri function to return the correct token URI
    function uri(uint256 tokenId) public view override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    // Fallback function to accept ETH
    receive() external payable {}

    // Function to handle direct ETH transfers
    fallback() external payable {}
}
