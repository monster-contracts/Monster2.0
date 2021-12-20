// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@cryptoshuraba/assetbox/contracts/Whitelist.sol";


contract Monster is ERC721, Whitelist{

    uint public count = 11001;
    string private _symbol;

    mapping(uint => string) public types;
    mapping(uint => string) public sizes;

    mapping(uint => string) public monsters;
    mapping(uint => uint32) public monsterCR;
    mapping(uint => uint32) public monsterHP;
    mapping(uint => uint32) public monsterType;
    mapping(uint => uint32) public monsterSize;

    struct ability {
        uint32 strength;
        uint32 dexterity;
        uint32 constitution;
        uint32 intelligence;
        uint32 wisdom;
        uint32 charisma;
    }

    mapping(uint => ability) public monsterAbility;

    struct original {
        uint from;
        uint32 generation;
        uint emergingTS;
        uint32 value;
    }
    mapping(uint => original) public monsterOriginal;
    mapping(uint => bool) public hatched;

    event claimed(uint tokenID, string monster, 
        uint32 cr, uint32 type_, uint32 size, uint32 hp,
        uint32 strength, uint32 dexterity, uint32 constitution, uint32 intelligence, uint32 wisdom, uint32 charisma);

    event inited(address owner, uint from, uint32 generation, uint emergingTS, uint32 value);

    constructor(string memory name_, string memory symbol_, address ms_) ERC721(name_, symbol_) Whitelist(ms_, symbol_) {
        _symbol = symbol_;

        types[1] = "Aberration";
        types[2] = "Animal";
        types[3] = "Construct";
        types[4] = "Dragon";
        types[5] = "Elemental";
        types[6] = "Fey";
        types[7] = "Giant";
        types[8] = "Humanoid";
        types[9] = "Magical Beast";
        types[10] = "Monstrous Humanoid";
        types[11] = "Ooze";
        types[12] = "Outsider";
        types[13] = "Plant";
        types[14] = "Undead";
        types[15] = "Vermin";

        sizes[1] = "Fine";
        sizes[2] = "Diminutive";
        sizes[3] = "Tiny";
        sizes[4] = "Small";
        sizes[5] = "Medium";
        sizes[6] = "Large";
        sizes[7] = "Huge";
        sizes[8] = "Gargantuan";
        sizes[9] = "Colossal";
    }

    function symbol() public view override(ERC721, Whitelist) returns (string memory) {
        return _symbol;
    }

    function init(address owner, uint from, uint32 generation, uint emergingTS, uint32 value) public is_approved {
        uint tokenID = count;
        count ++;
        _safeMint(owner, tokenID);

        emit inited(owner, from, generation, emergingTS, value);
    }

    function claim(uint tokenID, string memory monster, uint32 cr, uint32 type_, uint32 size, uint32 hp, uint32[] memory abilities) public is_approved{
        require(_exists(tokenID), "token hasn't minted");
        require(!hatched[tokenID], "token already hatched");
        
        monsters[tokenID] = monster;
        monsterCR[tokenID] = cr;
        monsterType[tokenID] = type_;
        monsterSize[tokenID] = size;
        monsterHP[tokenID] = hp;

        ability storage _attr = monsterAbility[tokenID];
        _attr.strength = abilities[0];
        _attr.dexterity = abilities[1];
        _attr.constitution = abilities[2];
        _attr.intelligence = abilities[3];
        _attr.wisdom = abilities[4];
        _attr.charisma = abilities[5];

        hatched[tokenID] = true;

        emit claimed(tokenID, monster, cr, type_, size, hp,
            abilities[0], abilities[1], abilities[2], abilities[3], abilities[4], abilities[5]);
    }

    function burn(uint tokenID) public is_approved{
        _burn(tokenID);
    }

    function tokenURI(uint tokenID) override public view returns (string memory) {
        string[23] memory parts;

        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="#160C0A" /><text x="10" y="20" class="base">';

        parts[1] = monsters[tokenID];

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = string(abi.encodePacked("CR", " ", toString(monsterCR[tokenID])));

        parts[4] = '</text><text x="10" y="60" class="base">';

        parts[5] = string(abi.encodePacked("Type", " ", types[monsterType[tokenID]]));

        parts[6] = '</text><text x="10" y="80" class="base">';

        parts[7] = string(abi.encodePacked("Size", " ", sizes[monsterSize[tokenID]]));

        parts[8] = '</text><text x="10" y="100" class="base">';

        parts[9] = string(abi.encodePacked("HP", " ", toString(monsterHP[tokenID])));

        parts[10] = '</text><text x="10" y="120" class="base">';

        parts[11] = string(abi.encodePacked("Strength", " ", toString(monsterAbility[tokenID].strength)));

        parts[12] = '</text><text x="10" y="140" class="base">';

        parts[13] = string(abi.encodePacked("Dexterity", " ", toString(monsterAbility[tokenID].dexterity)));

        parts[14] = '</text><text x="10" y="160" class="base">';

        parts[15] = string(abi.encodePacked("Constitution", " ", toString(monsterAbility[tokenID].constitution)));

        parts[16] = '</text><text x="10" y="180" class="base">';

        parts[17] = string(abi.encodePacked("Intelligence", " ", toString(monsterAbility[tokenID].intelligence)));

        parts[18] = '</text><text x="10" y="200" class="base">';

        parts[19] = string(abi.encodePacked("Wisdom", " ", toString(monsterAbility[tokenID].wisdom)));

        parts[20] = '</text><text x="10" y="220" class="base">';

        parts[21] = string(abi.encodePacked("Charisma", " ", toString(monsterAbility[tokenID].charisma)));

        parts[22] = '</text></svg>';

        string memory output = string(abi.encodePacked(
            parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], 
            parts[8], parts[9], parts[10]));
        
        output = string(abi.encodePacked(output, parts[11], parts[12], parts[13], parts[14], 
            parts[15], parts[16], parts[17], parts[18], parts[19], parts[20]));
        
        output = string(abi.encodePacked(output, parts[21], parts[22]));

        string memory json = Base64.encode(bytes(string(
            abi.encodePacked('{"name": "Bag #', toString(tokenID), '", "description": "Monster NFT is a kind of NFT assets randomized generated and stored on blockchain with different names, prefessions, basic attribute value and random attribute value, which can be used in any scene. The rarity of monster NFT is determined by its peofession, arrtribute value and game ecology. Level, scene and image is ommitted as part of further expansions.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}