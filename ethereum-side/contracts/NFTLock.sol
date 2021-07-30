pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./INFTLock.sol";

contract NFTLock is INFTLock, IERC721Receiver {

    mapping (address => (uint => bool)) isLocked;
    mapping (address => (uint256 => address)) owners;

    event TokenLocked(uint tokenId, address from);
    event TokenUnlocked(uint tokenId, address unlockerAddress);
    event NFTReceived(address from, bytes4 hash);
    event NFTWithdrawn(ERC721 nftContract, uint256 tokenId, address to);

    modifier isAuthorizedToUnlock(uint256 tokenId) {
        // check if WToken doesn't exist anymore before
        _;
    }

    // Deposit ERC721 token to be able to lock it
    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external returns(bytes4) {

        owners[msg.sender][tokenId] = from;
        emit NFTReceived(from,bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) );

        return 0x150b7a02;
    }

    function lockToken(uint256 tokenId) public {

        // check if token has been deposited
        require(owners[msg.sender][tokenId] != address(0), "NFT Locker: The token must be deposited before the lock");
        // check if token has not been locked yet
        require(!isLocked[msg.sender][tokenId], "NFT Locker: The token is already locked");

        isLocked[msg.sender][tokenId] = true;
        emit TokenLocked(tokenId, msg.sender);
    }

    function unlockToken( uint256 tokenId) public isAuthorizedToUnlock {

    require(owners[msg.sender][tokenId] == msg.sender, "NFT Locker: Only the Owner can unlock the Token");

        isLocked[msg.sender][tokenId] = false;
        emit TokenUnlocked(tokenId, msg.sender);
    }

    // Ensure that the token is not locked before to withdraw
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        require(isLocked[to][tokenId], "NFT Locker: Token is locked");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function withdraw(uint256 tokenId) external {

        require(owners[msg.sender][tokenId] == msg.sender, "NFT Locker: Only the Owner can unlock the Token");

        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        emit NFTWithdrawn(nftContract, tokenId, msg.sender);
    }
}
