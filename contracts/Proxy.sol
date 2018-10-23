pragma solidity ^0.4.24;

import "./AddressUtils.sol";
import "./Ownable.sol";

contract Registry is Ownable {

    event RegistryCreated(address addressOfRegistryContract,address from );

    mapping (address => address) public addresses;
    mapping (address => bool) public userPreferences;
    address[] public validImplementations;
    
  
    constructor() public {
        emit RegistryCreated(address(this),msg.sender);
    }
    function setImplementationAddress(address newAddress) public {
        require(newAddress != 0, "cant set value to 0");
        require(checkValidImplementationAddress(newAddress), "not a valid implementation address");
        addresses[msg.sender] = newAddress;
    }

    function checkValidImplementationAddress(address addr) internal view returns (bool) {
        for(uint i = 0; i < validImplementations.length; ++i) {
            if (addr == validImplementations[i]) return true;
        }
        return false;
    }

    function addImplementation(address toAdd) external onlyOwner {
        require(toAdd != 0);
        validImplementations.push(toAdd);
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
    
    function initialize(address _defLogicContract) internal {
        require(_defLogicContract != 0);
        require(Address.isContract(_defLogicContract));

        Registry registry = new Registry();
        address regAddress = address(registry);
       
        bytes32 reg = REGISTRY_IMPLEMENTATION_ADDRESS_KEY;
        bytes32 impl = DEFAULT_IMPLEMENTATION_ADDRESS_KEY;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(reg, regAddress)
            sstore(impl, _defLogicContract)
        }

        registry.addImplementation(_defLogicContract);

    }
    
    constructor(address _log) public {
        initialize( _log);
    }
    
    function upgradeDefaultImplementation(address _i) public {
        require(_i != 0);
        require(Address.isContract(_i));
        bytes32 impl = DEFAULT_IMPLEMENTATION_ADDRESS_KEY;
        bytes32 regKey = REGISTRY_IMPLEMENTATION_ADDRESS_KEY;
        address registryImpl = 0;
      
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(impl, _i)
            registryImpl := sload(regKey)
        }
        assert(registryImpl != 0);
        Registry reg = Registry(registryImpl);
        reg.addImplementation(_i);
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
    
    // at this point defImplAddress should not be 0
    
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


