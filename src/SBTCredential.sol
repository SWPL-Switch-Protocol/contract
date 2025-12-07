// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SBTCredential.sol
 * @notice 이 컨트랙트는 거래 증명을 위한 SoulBound Token(SBT)을 발행합니다.
 * @dev 전송이 불가능한 NFT(SBT) 구현체입니다.
 *      OpenZeppelin v5.0.0 이상의 ERC721을 기반으로 합니다.
 */
contract SBTCredential is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;
    string public constant description = "This SoulBound Token (SBTC) serves as a proof of transaction.";

    constructor(address initialOwner) ERC721("SBTCredential", "SBTC") Ownable(initialOwner) {}

    /**
     * @dev 새로운 SBT를 발행합니다. 오직 소유자(Admin)만 호출할 수 있습니다.
     * @param to 토큰을 받을 주소
     * @param uri 토큰의 메타데이터 URI
     */
    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /**
     * @dev 토큰 전송 로직을 제어합니다. SBT이므로 일반적인 전송은 금지됩니다.
     *      - Mint (from == 0): 허용
     *      - Burn (to == 0): 허용
     *      - Transfer (from != 0 && to != 0): 금지
     */
    function _update(address to, uint256 tokenId, address auth) internal override(ERC721) returns (address) {
        address from = _ownerOf(tokenId);
        
        // 민팅(Mint)이나 소각(Burn)이 아닌 경우, 즉 일반 전송인 경우 에러를 발생시킵니다.
        if (from != address(0) && to != address(0)) {
            revert("SoulBoundToken: Transfer is not allowed");
        }
        
        return super._update(to, tokenId, auth);
    }

    /**
     * @dev ERC721URIStorage의 tokenURI를 사용하기 위한 오버라이드
     */
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev ERC721URIStorage의 supportInterface를 사용하기 위한 오버라이드
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

