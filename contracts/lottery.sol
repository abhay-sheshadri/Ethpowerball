pragma solidity ^0.4.24;

import "./erc721.sol";

contract Powerball is ERC721 {

    uint  ticketPrice = 0.01 ether;
    uint private creationBlock;
    uint public whiteBallPrize = 0.01 ether;
    uint public redBallPrize = 0.01 ether;
    uint public jackpotPrize = 1 ether;
    uint public currentGeneration = 1;
    uint public interval = 500;

    uint8[] public powerballWinningNumbers = [0,0,0,0,0,0];
    uint8[] emptyArray;

    mapping (address => uint) public ownerTicketCount;
    mapping (uint => address) approvals;
    mapping (uint => Ticket[]) public lotteryTickets;

    address private owner;

    modifier onlyOwnerOf(address _addr) {
        require(_addr == owner);
        _;
    }

    struct Ticket {
        uint8[] numbers;
        address ownerOfTicket;
    }

    event PowerballTime(uint[] winningNumbers);

    constructor() public payable {
        owner = msg.sender;
        creationBlock = block.number;
    }

    function transferOwnership(address newOwner) external onlyOwnerOf(msg.sender) {
        owner = newOwner;
    }

    function setTicketPrice(uint newPrice) external onlyOwnerOf(msg.sender) {
        ticketPrice = newPrice;
    }

    function setWhiteBallPrize(uint newPrize) external onlyOwnerOf(msg.sender) {
        whiteBallPrize = newPrize;
    }

    function setRedBallPrize(uint newPrize) external onlyOwnerOf(msg.sender) {
        redBallPrize = newPrize;
    }

    function setJackpot(uint newPrize) external onlyOwnerOf(msg.sender) {
        jackpotPrize = newPrize;
    }

    function deposit() external payable returns (uint _amount) {
        _amount = msg.value;
    }

    function withdraw(uint amount) external onlyOwnerOf(msg.sender) {
        owner.transfer(amount);
    }

    function _isInArray(uint8[] numbers, uint8 number) private pure returns (uint8) {
        uint8 times = 0;
        for (uint i = 0; i < numbers.length; i++) {
            if (numbers[i] == number) {
                times++;
            }
        }
        return times;
    }

    function _addTicket(uint8[] numbers, address _player) private returns (uint _id) {
        require(numbers.length == 6 && numbers[5] >= 1 && numbers[5] <= 26);
        for (uint i = 0; i < 5; i++) {
            require(numbers[i] >= 1 && numbers[i] <= 59 && _isInArray(numbers, numbers[i]) == 1);
        }
        lotteryTickets[currentGeneration].push(Ticket(numbers, _player));
        ownerTicketCount[msg.sender]++;
        _id = lotteryTickets[currentGeneration].length - 1;
    }

    function buyTicket(uint8[] numbers) external payable returns (uint id) {
        require(msg.value == ticketPrice);
        id = _addTicket(numbers, msg.sender);
    }

    function getTicketInfo(uint _ticketId) external view returns (uint8[] ticketNumbers, address ticketOwner) {
        ticketNumbers = lotteryTickets[currentGeneration][_ticketId].numbers;
        ticketOwner = lotteryTickets[currentGeneration][_ticketId].ownerOfTicket;
    }

    function balanceOf(address _owner) public view returns (uint _balance) {
        _balance = ownerTicketCount[_owner];
    }

    function _transfer(address _from, address _to, uint256 _ticketId) private {
        ownerTicketCount[_to]++;
        ownerTicketCount[_from]--;
        lotteryTickets[currentGeneration][_ticketId].ownerOfTicket = _to;
        emit Transfer(_from, _to, _ticketId);
    }

    function transfer(address _to, uint256 _tokenId) public {
        require(msg.sender == lotteryTickets[currentGeneration][_tokenId].ownerOfTicket);
        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public {
        require(msg.sender == lotteryTickets[currentGeneration][_tokenId].ownerOfTicket);
        approvals[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        _owner = lotteryTickets[currentGeneration][_tokenId].ownerOfTicket;
    }

    function takeOwnership(uint256 _tokenId) public {
        require(approvals[_tokenId] == msg.sender);
        address _owner = ownerOf(_tokenId);
        _transfer(_owner, msg.sender, _tokenId);
    }

    function startPowerball() external onlyOwnerOf(msg.sender) returns (uint) {
        if (block.number - creationBlock % interval == 0) {
            powerballWinningNumbers = emptyArray;
            uint hash = uint(blockhash(block.number - 1));
            for (uint i =0; i < 5; i++) {
                powerballWinningNumbers.push(uint8((hash % 69) + 1));
                hash = uint(keccak256(hash));
            }
            powerballWinningNumbers.push(uint8((hash % 26) + 1));
            currentGeneration++;
        } else {
            return 1;
        }
    }

    function getWinningNumbers() external view returns (uint8[]) {
      return powerballWinningNumbers;
    }

    function claimPrize(uint _ticketId) external {
        uint8 totalWhiteBalls = 0;
        uint8 redBall;
        for (uint i = 0; i < 5; i++) {
            if (_isInArray(powerballWinningNumbers, lotteryTickets[currentGeneration - 1][_ticketId].numbers[i]) > 0) {
                totalWhiteBalls++;
            }
        }
        if (lotteryTickets[currentGeneration - 1][_ticketId].numbers[5] == powerballWinningNumbers[5]) {
                redBall++;
            }
        if (totalWhiteBalls + redBall != 6) {
            msg.sender.transfer(totalWhiteBalls * whiteBallPrize + redBall * redBallPrize);
        } else {
            msg.sender.transfer(jackpotPrize);
        }
    }
}
