

// handle access control/permission
contract Proxy {

    bytes32 private constant implementationAddressKey = keccak256("where the address will be stored");
    
    constructor(address _impl) public {
        // check that its valid before setting the address
        
        bytes32 slot = implementationAddressKey;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(slot, _impl)
        }
    }

    function implementation() public returns(address impl) {
        bytes32 slot = implementationAddressKey;
          //solium-disable-next-line security/no-inline-assembly
        assembly {
            impl := sload(slot)
        }
    }

    function setImplementation(address _impl) public {
        bytes32 slot = implementationAddressKey;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(slot, _impl)
        }
    }

    function () public {
        address localImpl = implementation();
         //solium-disable-next-line security/no-inline-assembly
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, localImpl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

}


contract ScoreStorage {

    uint256 public score;

}

contract Score is ScoreStorage {

    function setScore(uint256 _score) public {
        score = _score;
    }
}

contract ScoreV2 is ScoreStorage {

    function setScore(uint256 _score) public {
        score = _score * 5;
    }
}