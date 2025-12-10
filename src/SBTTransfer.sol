// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SBTCredential.sol
 * @notice This contract issues SoulBound Tokens (SBT) for proof of review.
 * @dev Implementation of non-transferable NFT (SBT).
 *      Based on OpenZeppelin v5.0.0+ ERC721.
 */
contract SBTTransfer is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;
    string public constant description = "This SoulBound Token (SBTT) serves as a proof of transfer.";

    constructor(address initialOwner) ERC721("SBTTransfer", "SBTT") Ownable(initialOwner) {}

    /**
     * @dev Issues a new SBT. Only the owner (Admin) can call this.
     * @param to Address to receive the token
     * @param uri Token metadata URI
     */
    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /**
     * @dev Controls token transfer logic. As it is an SBT, regular transfers are prohibited.
     *      - Mint (from == 0): Allowed
     *      - Burn (to == 0): Allowed
     *      - Transfer (from != 0 && to != 0): Prohibited
     */
    function _update(address to, uint256 tokenId, address auth) internal override(ERC721) returns (address) {
        address from = _ownerOf(tokenId);

        // If not minting or burning, i.e., a regular transfer, revert.
        if (from != address(0) && to != address(0)) {
            revert("SoulBoundToken: Transfer is not allowed");
        }

        return super._update(to, tokenId, auth);
    }

    /**
     * @dev Override to use ERC721URIStorage's tokenURI
     */
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev Override to use ERC721URIStorage's supportInterface
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

