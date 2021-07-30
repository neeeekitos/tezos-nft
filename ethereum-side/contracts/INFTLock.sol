pragma solidity 0.8.6;

contract INFTLock {

    function lockToken(uint256 tokenId) public;
    function unlockToken( uint256 tokenId) public isAuthorizedToUnlock;
    function withdraw(uint256 tokenId) external;
}
