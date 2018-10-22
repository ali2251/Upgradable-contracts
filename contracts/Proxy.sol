pragma solidity ^0.4.24;

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
    
    function setImpl(address _i) public {
        bytes32 s = REGISTRY_IMPLEMENTATION_ADDRESS_KEY;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(s, _i)
        }
    }

    function() public {
        
        bytes32 s = REGISTRY_IMPLEMENTATION_ADDRESS_KEY;
        bytes32 l = DEFAULT_IMPLEMENTATION_ADDRESS_KEY;
        address impl = 0;
        address realImpl = 0;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            impl := sload(s)
            realImpl := sload(l)
        }
    
        require(impl != 0);

        Registry r = Registry(impl);
    
        if(r.userPreferences(msg.sender) == true) {
            // means that user may have a different address for implementation
            
            if ( r.addresses(msg.sender) != 0) {
                // they dont have it set, lets use default one
                realImpl =  r.addresses(msg.sender);
            }
        }
    
    // at this point realImpl should not be 0
    
        assert(realImpl != 0);
    
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, realImpl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
    
}


