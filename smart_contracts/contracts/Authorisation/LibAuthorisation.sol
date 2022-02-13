pragma solidity ^0.8.0;

library LibAuthorisation{
    
    bytes private constant AUTHORISATION_STORAGE = "lib.authorisation";

    struct AuthorisationStorage{
        address contractOwner;
        mapping(address => Authorisation) authorisations;
        address[] authorisationIndex;
    }

    struct Authorisation{
        address owner;
        Permissions permission;
    }

    enum Permissions{
        unrecognised,
        user,
        admin,
        count
    }

    modifier onlyContractOwner()
    {
        AuthorisationStorage storage authStore = LibAuthorisation.authorisationStorage();
        require(msg.sender == authStore.contractOwner);
        _;   
    }
    
    function isUser(address _address) internal view returns (bool authorised){
        AuthorisationStorage storage authStore = authorisationStorage();
        return authStore.authorisations[_address].permission == Permissions.user;
    }

    function isAdmin(address _address) internal view returns (bool authorised){
        AuthorisationStorage storage authStore = authorisationStorage();
        return authStore.authorisations[_address].permission == Permissions.admin;
    }

    function authorisationStorage() internal pure returns(AuthorisationStorage storage authStore) {
        bytes32 AUTHORISATION_STORAGE_POSITION = keccak256(AUTHORISATION_STORAGE);
        assembly {authStore.slot := AUTHORISATION_STORAGE_POSITION}
    }
}