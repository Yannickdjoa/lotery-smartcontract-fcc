//Raffle
//enter raffle paying entrance fee
//pick a random winner from participants
//use chainlink VRF to pick generate the random number

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

error Raffle__NotEnoughEth();
error Raffle__upkeepNotNeeded(uint256 currentBalance, uint256 numplayers, uint256 raffleState);
error Raffle__TransferFailed();
error Raffle__NotOpen();

contract Raffle is VRFConsumerBaseV2, AutomationCompatibleInterface {
    /*types variables */
    enum RaffleState {
        OPEN,
        CALCULATING
    }
    /*State variables */
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    address payable[] public s_players;
    uint256 private immutable i_Interval;
    bytes32 private immutable i_gasLane;
    uint64 private s_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 4;
    uint32 private immutable i_CallbackGasLimit;
    uint32 private constant NUM_WORDS = 1;

    /*lotery variables */
    uint256 private immutable i_entranceFee;
    uint256 private immutable s_LastTimeStamp;
    RaffleState private s_raffleState;
    address private s_recentWinner;

    /*events */
    event RequestedRaffleWinner(uint256 requestId);
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed player);

    constructor(
        uint256 entranceFee,
        address vrfCoordinatorV2,
        uint256 interval,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_Interval = interval;
        s_LastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
        i_gasLane = gasLane;
        s_subscriptionId = subscriptionId;
        i_CallbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() public payable {
        //allow people to enter the raffle
        //require(msg.value > i_entranceFee, "not enough eth");
        s_raffleState = RaffleState.OPEN;
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEth();
        }
        //enable to enter only when lotery in open state
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__NotOpen();
        }

        //list of players
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    // 2 functions to have here
    //1. request random word. function requesting randomness
    //2. fullfillrandomword which is the function that does something with the random word requested

    function checkUpkeep(
        bytes memory /*checkData*/
    ) public view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
        //what we need for checkupkeep to return true
        //1. time interval
        //2. Raffle's state open
        //3. enough players
        //4. enough eth
        bool timePassed = (block.timestamp - s_LastTimeStamp) > i_Interval;
        bool isOpen = (RaffleState.OPEN == s_raffleState);
        bool hasPlayers = s_players.length > 0;
        bool hasBalance = (address(this).balance) > 0;

        upkeepNeeded = (timePassed && isOpen && hasPlayers && hasBalance);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__upkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, //keyHash,
            s_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_CallbackGasLimit,
            NUM_WORDS
        );
        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(
        uint256,
        /*requestId*/ uint256[] memory randomWords
    ) internal override {
        //winner picked
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        //reopen the raffle
        s_raffleState = RaffleState.OPEN;
        //once winner picked reset list of players
        s_players = new address payable[](0);

        //send ETH to winner
        (bool sent, ) = recentWinner.call{value: address(this).balance}("");
        if (!sent) {
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked(recentWinner);
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }

    function getplayers(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }

    function getLatestTimeStamp() public view returns (uint256) {
        return s_LastTimeStamp;
    }

    function getRequestConfirmations() public pure returns (uint256) {
        return REQUEST_CONFIRMATIONS;
    }

    function getNumWords() public pure returns (uint256) {
        return NUM_WORDS;
    }
}
