// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "hardhat/console.sol";

contract ChainBattles is ERC721URIStorage {
  using Strings for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  struct Stat {
    uint256 hp;
    uint256 attack;
    uint256 defense;
    uint256 stamina;
  }

  uint256 modulus = 10;

  function randomDigit() private view returns (uint256 hp, uint256 attack, uint256 defense, uint256 stamina) {
    uint256 randHp = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % modulus;
    uint256 randAttack = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % modulus;
    uint256 randDefense = uint256(keccak256(abi.encodePacked(msg.sender, block.difficulty))) % modulus;
    uint256 randStamina = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % modulus;
    return (randHp, randAttack, randDefense, randStamina);

  }

  mapping (uint256 => uint256) public tokenIdtoLevels;
  mapping (uint256 => Stat) public tokenIdtoStats;

  constructor() ERC721("Chain Battles", "CBTLS"){

  }

  function generateCharacter(uint256 tokenId) public view returns(string memory) {
    bytes memory svg = abi.encodePacked(
      '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
      '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
      '<rect width="100%" height="100%" fill="black" />',
      '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
      '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevels(tokenId),'</text>',
      '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "HP: ",getHp(tokenId),'</text>',
      '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Attack: ",getAttack(tokenId),'</text>',
      '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Defense: ",getDefense(tokenId),'</text>',
      '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Stamina: ",getStamina(tokenId),'</text>',
      '</svg>'
    );

    return string(
      abi.encodePacked(
        "data:image/svg+xml;base64,",
        Base64.encode(svg)
      )
    );
  }

  function getLevels(uint256 tokenId) public view returns(string memory) {
    uint256 levels = tokenIdtoLevels[tokenId];
    return levels.toString();
  }

  function getStats(uint256 tokenId) public view returns(
    uint256 hp,
    uint256 attack,
    uint256 defense,
    uint256 stamina
  ) {
    hp = tokenIdtoStats[tokenId].hp;
    attack = tokenIdtoStats[tokenId].attack;
    defense = tokenIdtoStats[tokenId].defense;
    stamina = tokenIdtoStats[tokenId].stamina; 
  }

  function getHp(uint256 tokenId) public view returns(string memory) {
    uint256 hp;
    (hp,,,) = getStats(tokenId);
    return hp.toString();
  }

  function getAttack(uint256 tokenId) public view returns(string memory) {
    uint256 attack;
    (,attack,,) = getStats(tokenId);
    return attack.toString();
  }

  function getDefense(uint256 tokenId) public view returns(string memory) {
    uint256 defense;
    (,,defense,) = getStats(tokenId);
    return defense.toString();
  }

  function getStamina(uint256 tokenId) public view returns(string memory) {
    uint256 stamina;
    (,,,stamina) = getStats(tokenId);
    return stamina.toString();
  }

  function getTokenURI(uint256 tokenId) public view returns (string memory){
    bytes memory dataURI = abi.encodePacked(
        '{',
            '"name": "Chain Battles #', tokenId.toString(), '",',
            '"description": "Battles on chain",',
            '"image": "', generateCharacter(tokenId), '"',
        '}'
    );
    return string(
        abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(dataURI)
        )
    );
  }

  function mint() public {
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);
    tokenIdtoLevels[newItemId] = 0;
    train(newItemId);
    _setTokenURI(newItemId, getTokenURI(newItemId));
  }

  function train(uint256 tokenId) public {
    require(_exists(tokenId), "Please use an existing Token");
    require(ownerOf(tokenId) == msg.sender, "Please use your own Token");
    uint256 currentLevel = tokenIdtoLevels[tokenId];
    tokenIdtoLevels[tokenId] = currentLevel + 1;
    (uint256 hpTrain,,,) = randomDigit();
    (,uint256 attackTrain,,) = randomDigit();
    (,,uint256 defenseTrain,) = randomDigit();
    (,,,uint256 staminaTrain) = randomDigit();
    tokenIdtoStats[tokenId].hp += hpTrain;
    tokenIdtoStats[tokenId].attack += attackTrain;
    tokenIdtoStats[tokenId].defense += defenseTrain;
    tokenIdtoStats[tokenId].stamina += staminaTrain;
    console.log("training");
    _setTokenURI(tokenId, getTokenURI(tokenId));
  }


}