
// SPDX-License-Identifier: UNLICENSED

//                                                                                   ↑↑↑↑
//   ↑↑↑          ↑↑                                                                 ↑↑↑↑↑
// ↑↑↑↑↑↑↑      ↑↑↑↑↑↑↑    ↑↑↑     ↑↑      ↑↑↑      ↑↑↑↑↑↑     ↑↑↑↑↑↑↑   ↑↑     ↑↑↑       
// ↑↑↑↑↑↑↑      ↑↑↑↑↑↑↑     ↑↑↑   ↑↑↑   ↑↑↑↑↑↑↑↑↑   ↑↑↑↑↑↑↑↑   ↑↑↑↑↑↑↑   ↑↑↑↑  ↑↑↑        
// ↑↑↑↑↑↑↑↑↑   ↑↑↑↑↑↑↑↑      ↑↑↑  ↑↑↑  ↑↑↑     ↑↑↑        ↑↑               ↑↑↑↑↑↑         
//  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑         ↑↑↑↑↑↑↑  ↑↑       ↑↑  ↑↑↑↑↑↑↑↑   ↑↑↑↑↑↑       ↑↑↑↑          
//       ↑↑↑↑↑↑↑↑    ↑↑↑↑↑      ↑↑↑↑↑  ↑↑↑    ↑↑↑↑  ↑↑↑↑↑↑↑                ↑↑↑↑↑↑         
//       ↑↑↑↑↑↑↑    ↑↑↑↑↑↑       ↑↑↑↑   ↑↑↑↑↑↑↑↑↑   ↑↑   ↑↑↑   ↑↑↑↑↑↑↑   ↑↑↑   ↑↑↑↑       
//        ↑↑↑↑↑↑     ↑↑↑↑↑        ↑↑↑      ↑↑↑      ↑↑    ↑↑↑  ↑↑↑↑↑↑↑   ↑↑      ↑↑      



pragma solidity ^0.8.4;

// import "token/ERC20/ERC20.sol";
// import "token/ERC20/extensions/ERC20Permit.sol";


//can also use openzeppelin contracts directly
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";


contract Vorex is ERC20, ERC20Permit {
    mapping(address => uint256) public replayNonce;

    constructor() ERC20("Vorex AI Token", "VOREX") ERC20Permit("Vorex AI Token") {
        _mint(
            0x3B27463262ff29935C1DD387FD7e6966c6BC55DF,
            40000000 * 10 ** decimals()
        );
        _mint(
            0x00F5A53Ea12afe2F92216FB8B2a46DC73B2DEDC1,
            30000000 * 10 ** decimals()
        );
        _mint(
            0x38e5ED8aaa1fb526b66B80045e95A994e499a03D,
            20000000 * 10 ** decimals()
        );
        _mint(
            0x7205967a559F44258A83e416E4dc3d7f6AA7727b,
            10000000 * 10 ** decimals()
        );
    }

    function metaTransfer(
        bytes memory signature,
        address to,
        uint256 value,
        uint256 nonce,
        uint256 reward
    ) public returns (bool) {
        bytes32 metaHash = metaTransferHash(to, value, nonce, reward);
        address signer = getSigner(metaHash, signature);
        require(signer != address(0));
        require(nonce == replayNonce[signer]);
        replayNonce[signer]++;
        _transfer(signer, to, value);
        if (reward > 0) {
            _transfer(signer, msg.sender, reward);
        }
        return true;
    }

    function metaTransferHash(
        address to,
        uint256 value,
        uint256 nonce,
        uint256 reward
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    address(this),
                    "metaTransfer",
                    to,
                    value,
                    nonce,
                    reward
                )
            );
    }

    function getSigner(
        bytes32 _hash,
        bytes memory _signature
    ) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (_signature.length != 65) {
            return address(0);
        }
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }
        if (v != 27 && v != 28) {
            return address(0);
        } else {
            return
                ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            _hash
                        )
                    ),
                    v,
                    r,
                    s
                );
        }
    }

    function getNonce(address ethAddress) public view returns (uint256) {
        return replayNonce[ethAddress];
    }
    function getNonce32(address ethAddress) public view returns (uint256) {
        return replayNonce[ethAddress];
    }
}

