// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Charity {
    address public admin;
    mapping(address => CharityOrg) charities;
    mapping(address => Donator) donators;
    DonationDetail[] public donationDetails;

    constructor() {
        admin = msg.sender;
    }

    struct CharityOrg {
        string name;
        string phone;
        bool isVerify;
        uint256 balance;
        address[] whoDonateMe;
    }

    struct Donator {
        string name;
        address[] donateToCharity;
    }

    struct DonationDetail {
        address charityOrgAddress;
        address donatorAddress;
        uint256 datetime;
        uint256 amount;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function addCharityOrg(string memory _name, string memory _phone) public {
        require(bytes(_name).length > 0, "Charity name cannot be empty");
        require(bytes(_phone).length > 0, "Charity phone number cannot be empty");

        CharityOrg memory newCharityOrg = CharityOrg({
            name: _name,
            phone: _phone,
            isVerify: false,
            balance: 0,
            whoDonateMe: new address[](0)
        });
        charities[msg.sender] = newCharityOrg;
    }

    function donate(address _charityAddress, string memory _donatorName) public payable returns (DonationDetail memory) {
        require(msg.value > 0, "Donation amount must be greater than 0");
        require(charities[_charityAddress].isVerify, "Charity organization is not verified");

        charities[_charityAddress].balance += msg.value;
        charities[_charityAddress].whoDonateMe.push(msg.sender);

        if (bytes(_donatorName).length > 0) {
            donators[msg.sender].name = _donatorName;
        } else {
            donators[msg.sender].name = "Anonymous";
        }

        donators[msg.sender].donateToCharity.push(_charityAddress);
        DonationDetail memory newDonationDetail = DonationDetail({
            charityOrgAddress: _charityAddress,
            donatorAddress: msg.sender,
            datetime: block.timestamp,
            amount: msg.value
        });
        donationDetails.push(newDonationDetail);
        return newDonationDetail;
    }

    function verifyCharity(address _charityAddress) public onlyAdmin {
        charities[_charityAddress].isVerify = true;
    }

    function withdraw() public {
        require(charities[msg.sender].balance > 0, "No funds available for withdrawal");

        uint256 amount = charities[msg.sender].balance;
        charities[msg.sender].balance = 0;

        payable(msg.sender).transfer(amount);
    }

    function getCharity(address _charityAddress) public view returns (CharityOrg memory) {
        return charities[_charityAddress];
    }

    function getDonationData() public view onlyAdmin returns (DonationDetail[] memory) {
        return donationDetails;
    }

    function getDonator(address _donatorAddress) public view returns (Donator memory) {
        return donators[_donatorAddress];
    }
}
