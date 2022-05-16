// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract SHEBA {
    string public name = "SHEBA";
    uint256 public fileCount = 0;
    mapping(uint256 => File) public files;

    struct File {
        uint256 fileId;
        string filePath;
        uint256 fileSize;
        string fileType;
        string fileName;
        string subject;
        string paperType;
        address connectedTo;
        address payable uploader;
    }

    event FileUploaded(
        uint256 fileId,
        string filePath,
        uint256 fileSize,
        string fileType,
        string fileName,
        string subject,
        string paperType,
        address connectedTo,
        address payable uploader
    );

    function uploadFile(
        string memory _filePath,
        uint256 _fileSize,
        string memory _fileType,
        string memory _fileName,
        string memory _subject,
        string memory _paperType,
        address _connectedTo
    ) public {
        require(bytes(_filePath).length > 0);
        require(bytes(_fileType).length > 0);
        require(bytes(_fileName).length > 0);
        require(bytes(_subject).length > 0);
        require(msg.sender != address(0));
        require(_fileSize > 0);

        fileCount++;

        files[fileCount] = File(
            fileCount,
            _filePath,
            _fileSize,
            _fileType,
            _fileName,
            _subject,
            _paperType,
            _connectedTo,
            payable(msg.sender)
        );
        
        emit FileUploaded(
            fileCount,
            _filePath,
            _fileSize,
            _fileType,
            _fileName,
            _subject,
            _paperType,
            _connectedTo,
            payable(msg.sender)
        );
    }
}
