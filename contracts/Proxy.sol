pragma solidity ^0.4.24;

import "./AddressUtils.sol";

contract Registry {
    mapping (address => address) public addresses;
    mapping (address => bool) public userPreferences;
    
    function setAddress(address newAddress) public {
        require(newAddress != 0);
        addresses[msg.sender] = newAddress;
    }
    
    function updatePreference(bool newPref) public {
        userPreferences[msg.sender] = newPref;
    }
}

contract Hello {
    address public me = 0;
    function sayHello() public pure returns(string) {
        return "Hello";
    }
}


contract HelloV2 is Hello {
    uint public abc = 1234;
    function sayHello() public pure returns (string) {
        return "hello v2";
    }
}

contract Proxy {
  
    bytes32 private constant REGISTRY_IMPLEMENTATION_ADDRESS_KEY = keccak256("Registry address key");
    bytes32 private constant DEFAULT_IMPLEMENTATION_ADDRESS_KEY = keccak256("default implementation address key");
    
    function initialize(address _registryImpl,address _defLogicContract) internal {
        require(_registryImpl != 0);
        require(_defLogicContract != 0);
        require(Address.isContract(_registryImpl));
        require(Address.isContract(_defLogicContract));

        bytes32 reg = REGISTRY_IMPLEMENTATION_ADDRESS_KEY;
        bytes32 impl = DEFAULT_IMPLEMENTATION_ADDRESS_KEY;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(reg, _registryImpl)
            sstore(impl, _defLogicContract)
        }
    }
    
    constructor(address _reg, address _log) public {
        initialize(_reg, _log);
    }
    
    function upgradeDefaultImplementation(address _i) public {
        require(_i != 0);
        require(Address.isContract(_i));
        bytes32 impl = DEFAULT_IMPLEMENTATION_ADDRESS_KEY;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(impl, _i)
        }
    }

    function() public {
        
        bytes32 regImplKey = REGISTRY_IMPLEMENTATION_ADDRESS_KEY;
        bytes32 defImplKey = DEFAULT_IMPLEMENTATION_ADDRESS_KEY;
        address regImplAddress = 0;
        address defImplAddress = 0;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            regImplAddress := sload(regImplKey)
            defImplAddress := sload(defImplKey)
        }
    
        require(regImplAddress != 0 && defImplAddress != 0);

        Registry r = Registry(regImplAddress);
    
        if(r.userPreferences(msg.sender) == true) {
            // means that user may have a different address for implementation
            
            if ( r.addresses(msg.sender) != 0) {
                // they dont have it set, lets use default one
                defImplAddress = r.addresses(msg.sender);
            }
        }
    
    // at this point realImpl should not be 0
    
        assert(defImplAddress != 0);
    
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, defImplAddress, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
    
}


