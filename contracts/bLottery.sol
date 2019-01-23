pragma solidity ^0.5.0;

contract bLottery {
    
    struct ticket {
        address ownerAddress;
        string ticketNo;
    }
        
    mapping (address => uint) public ticketOwners;
    address payable[] public allOwners;
    address[] public pastWinners;
    address public lastWinner;
    uint public ticketsBought;
    uint public lotteryTotal;
    uint public totalWon;
    uint public timeStarted;
    uint public willLast;
    bool public lotteryOver;
    
    event TicketSold(address to, uint amount);
    event PayWinner(address payable to, uint amount);
    event Reset();
    event SetMessage(string message);
    
    modifier currentLottery() {
        require(now < timeStarted + willLast);
        _;
    }
    modifier lotteryDone() {
        require(now > timeStarted + willLast);
        _;
    }

    constructor() public {
        ticketsBought = 0;
        timeStarted = now;
        willLast = 10 seconds;
    }

    function sellTickets() external payable currentLottery returns (bool success) {
        ticketOwners[msg.sender] = msg.value / (10**15);
        ticketsBought += ticketOwners[msg.sender];
        allOwners.push(msg.sender);
        lotteryTotal += msg.value;
        emit TicketSold(msg.sender, ticketOwners[msg.sender]);
        return true;
    }

    function reboot() public lotteryDone returns (bool success) {
        lotteryOver = false;
        timeStarted = now;
        willLast = 2 minutes;
        emit Reset();
        return true;
    }

    function payWinner(address payable winner) internal currentLottery returns (bool success) {
        winner.transfer(lotteryTotal);
        emit PayWinner(winner, lotteryTotal);
        lotteryTotal = 0;
        emit Reset();
        return true;
    }

    function selectWinner() public lotteryDone() returns (uint winningTicket) {
        uint random = uint(blockhash(block.number - 1)) % timeStarted + 1;
        address payable lastWinner = allOwners[random];
        pastWinners.push(lastWinner);
        payWinner(lastWinner);
        return random;
    }

    function getOwnerBalance(address ownerAddress) public returns (uint balance) {
        return ticketOwners[ownerAddress];
    }

    function getBalance() public returns (uint) {
        return address(this).balance;
    }
	
    function setmessage(string memory message) public returns (bool success) {
        emit SetMessage(message);
    }

    function timeLeft() public returns (uint) {
        return timeStarted;
    }
}