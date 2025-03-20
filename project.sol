// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificationNFT {

    uint256 public certificateCounter;
    string public name = "CertificationNFT";
    string public symbol = "CNFT";

    struct Certificate {
        string courseName;
        address recipient;
        uint256 issueDate;
    }

    mapping(uint256 => Certificate) public certificates;
    mapping(uint256 => address) public certificateOwner;
    mapping(address => uint256[]) public userCertificates;

    event CertificateIssued(uint256 certificateId, address recipient, string courseName, uint256 issueDate);
    event CertificateTransferred(uint256 certificateId, address from, address to);

    modifier onlyOwnerOf(uint256 _certificateId) {
        require(certificateOwner[_certificateId] == msg.sender, "You do not own this certificate");
        _;
    }

    // Create a new certificate (NFT)
    function issueCertificate(address _recipient, string memory _courseName) external {
        certificateCounter++;
        uint256 certificateId = certificateCounter;

        certificates[certificateId] = Certificate({
            courseName: _courseName,
            recipient: _recipient,
            issueDate: block.timestamp
        });

        certificateOwner[certificateId] = _recipient;
        userCertificates[_recipient].push(certificateId);

        emit CertificateIssued(certificateId, _recipient, _courseName, block.timestamp);
    }

    // Get certificate details
    function getCertificateDetails(uint256 _certificateId) external view returns (Certificate memory) {
        return certificates[_certificateId];
    }

    // Transfer certificate ownership
    function transferCertificate(uint256 _certificateId, address _to) external onlyOwnerOf(_certificateId) {
        address from = certificateOwner[_certificateId];
        certificateOwner[_certificateId] = _to;

        // Remove certificate from the sender's list
        uint256[] storage senderCertificates = userCertificates[from];
        for (uint256 i = 0; i < senderCertificates.length; i++) {
            if (senderCertificates[i] == _certificateId) {
                senderCertificates[i] = senderCertificates[senderCertificates.length - 1];
                senderCertificates.pop();
                break;
            }
        }

        // Add certificate to the receiver's list
        userCertificates[_to].push(_certificateId);

        emit CertificateTransferred(_certificateId, from, _to);
    }

    // Get all certificates of a user
    function getUserCertificates(address _user) external view returns (uint256[] memory) {
        return userCertificates[_user];
    }
}
