// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DSCEngine} from "src/DSCEngine.sol";
import {DeployDSC} from "script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract DSCEngineTest is Test {
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine dsce;
    HelperConfig helperConfig;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address weth;

    uint256 public constant AMOUNT_COLATERAL = 10 ether;

    address public constant USER = address(1);

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, helperConfig) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth,,) = helperConfig.activeNetworkConfig();
        // vm.deal(USER, 100 ether);
        console.log(weth, "hello");
    }

    ///////////////////////
    // Constructor Tests //
    ///////////////////////

    address[] public tokenAddresses;
    address[] public feedAddresses;

    function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {
        tokenAddresses.push(weth);
        feedAddresses.push(ethUsdPriceFeed);
        feedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength.selector);
        new DSCEngine(tokenAddresses, feedAddresses, address(dsc));
    }

    //////////////////
    // Price Tests //
    //////////////////

    function testGetTokenAmountFromUsd() public {
        // If we want $100 of WETH @ $2000/WETH, that would be 0.05 WETH
        uint256 expectedWeth = 0.05 ether;
        uint256 amountWeth = dsce.getTokenAmountFromUsd(weth, 100 ether);
        assertEq(amountWeth, expectedWeth);
    }

    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        // 15e18 ETH * $2000/ETH = $30,000e18
        uint256 expectedUsd = 30_000e18;
        uint256 usdValue = dsce.getUsdValue(weth, ethAmount);
        console.log(usdValue);
        assertEq(usdValue, expectedUsd);
    }

    ///////////////////////////////////////
    // depositCollateral Tests //
    ///////////////////////////////////////

    function testRevertsIfCollateralZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dsce), AMOUNT_COLATERAL);
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        dsce.depositCollateral(weth, 0);
        vm.stopPrank();
    }

    function testRevertsWithUnapprovedCollateral() public {
        ERC20Mock ranToken = new ERC20Mock("RAN", "RAN", USER, AMOUNT_COLATERAL);
        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine__TokenNotAllowed.selector, address(ranToken)));
        dsce.depositCollateral(address(ranToken), AMOUNT_COLATERAL);
    }

    // modifier depositedCollateral() {
    //     vm.startPrank(USER);
    //     ERC20Mock(weth).approve(address(dsce), AMOUNT_COLATERAL);
    //     dsce.depositCollateral(weth, AMOUNT_COLATERAL);
    //     vm.stopPrank();
    //     _;
    // }

    // function testCanDepositedCollateralAndGetAccountInfo() public depositedCollateral {
    //     (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(USER);
    //     uint256 expectedDepositedAmount = dsce.getTokenAmountFromUsd(weth, collateralValueInUsd);
    //     assertEq(totalDscMinted, 0);
    //     assertEq(expectedDepositedAmount, AMOUNT_COLATERAL);
    // }

    ///////////////////////////////////////
    // depositCollateralAndMintDsc Tests //
    ///////////////////////////////////////

    // function testRevertsIfMintedDscBreaksHealthFactor() public {
    //     (, int256 price,,,) = MockV3Aggregator(ethUsdPriceFeed).latestRound();
    //     amountToMint = (AMOUNT_COLATERAL * (uint256(price) * dsce.getAdditionalFeedPrecision())) / dsce.getPrecision();
    //     vm.startPrank(USER);
    //     ERC20Mock(weth).approve(address(dsce), AMOUNT_COLATERAL);
    //     uint256 expectedHealthFactor =
    //         dsce.calculateHealthFactor(amountToMint, dsce.getUsdValue(weth, AMOUNT_COLATERAL));
    //     vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine__BreaksHealthFactor.selector, expectedHealthFactor));
    //     dsce.depositCollateralAndMintDsc(weth, AMOUNT_COLATERAL, amountToMint);
    //     vm.stopPrank();
    // }
}
