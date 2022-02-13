pragma solidity ^0.8.0;

import "./LibAuthorisation.sol";

contract Authorisation{

    // Used for self proxy calls 
    modifier onlyThis(address _address)
    {
        require(msg.sender == address(this));
        _;
    }

    modifier onlyAdmin()
    {
        LibAuthorisation.AuthorisationStorage storage authStore = LibAuthorisation.authorisationStorage();
        require(authStore.authorisations[msg.sender].permission == LibAuthorisation.Permissions.admin);
        _;
    }

    modifier onlyContractOwner()
    {
        LibAuthorisation.AuthorisationStorage storage authStore = LibAuthorisation.authorisationStorage();
        require(msg.sender == authStore.contractOwner);
        _;   
    }

    modifier validPermission(
        LibAuthorisation.Permissions _permission)
    {
        require (_permission < LibAuthorisation.Permissions.count);
        _;
    }

    modifier existingUser(address owner)
    {
        LibAuthorisation.AuthorisationStorage storage authStore = LibAuthorisation.authorisationStorage();
        require (authStore.authorisations[owner].permission != LibAuthorisation.Permissions.unrecognised);
        _;
    }

    /// @notice CRUD for authorisations
    /// @dev Uses a statically sized struct as input (Web3j compatible)
    /// @return success CRUD operation status
    function createUser(LibAuthorisation.Authorisation memory _authorisation) 
        external 
        validPermission(_authorisation.permission) 
        existingUser(_authorisation.owner) 
        returns (bool success)
    {
        LibAuthorisation.AuthorisationStorage storage authStore = LibAuthorisation.authorisationStorage();

        // Can only create standard users
        require (_authorisation.permission != LibAuthorisation.Permissions.admin);
        // Must be a new user
        require (authStore.authorisations[_authorisation.owner].permission == LibAuthorisation.Permissions.unrecognised);

        authStore.authorisations[_authorisation.owner] = _authorisation;
        authStore.authorisationIndex.push(_authorisation.owner);

        return true;
    }

    function createAdmin(LibAuthorisation.Authorisation memory _authorisation) 
        external 
        onlyContractOwner
        validPermission(_authorisation.permission) 
        existingUser(_authorisation.owner) 
        returns (bool success)
    {
        LibAuthorisation.AuthorisationStorage storage authStore = LibAuthorisation.authorisationStorage();
        
        require (authStore.authorisations[_authorisation.owner].permission == LibAuthorisation.Permissions.unrecognised);
        authStore.authorisations[_authorisation.owner] = _authorisation;
        authStore.authorisationIndex.push(_authorisation.owner);

        return true;
    }

    function getAuthorisation(address _address) 
        external 
        view 
        existingUser(_address) 
        returns (
            bool success, 
            LibAuthorisation.Authorisation memory authorisation)
    {
        LibAuthorisation.AuthorisationStorage storage authStore = LibAuthorisation.authorisationStorage();
        authorisation = authStore.authorisations[_address];
        if (authorisation.owner != address(0)) success = true;
    }

    function updateAuthorisation(LibAuthorisation.Authorisation memory _authorisation) 
        external 
        existingUser(_authorisation.owner) 
        returns (bool success)
    {
        require(_authorisation.owner != address(0));
        LibAuthorisation.AuthorisationStorage storage authStore = LibAuthorisation.authorisationStorage();
        authStore.authorisations[_authorisation.owner] = _authorisation;
        return true;
    }

    function deleteAuthorisation (address _address) 
        external 
        existingUser(_address)
        onlyAdmin 
        returns (bool success)
    {
        LibAuthorisation.AuthorisationStorage storage authStore = LibAuthorisation.authorisationStorage();
        for (uint i; i < authStore.authorisationIndex.length; i++){
            if (authStore.authorisationIndex[i] == _address){
                delete authStore.authorisationIndex[i];
                delete authStore.authorisations[_address];
                success = true;
            }
        }
    }
}