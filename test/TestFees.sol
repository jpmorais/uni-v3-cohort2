pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/UniswapV3Factory.sol"; 
import "../src/UniswapV3Pool.sol";
import "../src/Token.sol";
import "../src/interfaces/callback/IUniswapV3MintCallback.sol";
import "../src/interfaces/callback/IUniswapV3SwapCallback.sol";
import {Tick} from "../src/libraries/Tick.sol";

contract MintTest is Test, IUniswapV3MintCallback {

    UniswapV3Factory factory;
    UniswapV3Pool pool;
    Token tokenA;
    Token tokenB;

    address alice = address(0xA11CE);
    address bob = address(0xB0B);


    function setUp() public {
        tokenA = new Token("Token A", "TKA");
        tokenB = new Token("Token B", "TKB");
        factory = new UniswapV3Factory();
        pool = UniswapV3Pool(factory.createPool(address(tokenA), address(tokenB), 500));

        // tick 0
        uint160 initialPrice = 79228162514264337593543950336;
        pool.initialize(initialPrice);


    }

    function testFeeGrowOne() public {


        uint256 feeGrowthBefore = pool.feeGrowthGlobal1X128();
        console.log("FEE GROWTH BEFORE", feeGrowthBefore);

        (uint amount0A, uint amount1A) = pool.mint(address(this),-10,10,10**8,"");
        (uint amount0B, uint amount1B) = pool.mint(address(this),10,20,2*10**8,"");
        (uint amount0C, uint amount1C) = pool.mint(address(this),20,40,3*10**8,"");


        // zero for one
        (int amount0swap, int amount1swap) = pool.swap(address(this), false, 300_000, 779625275426524698543654961152, "");
        //console.log(amount0swap);
        //console.log(amount1swap);

        (uint160 sqrtPriceX96, int24 tick, , ,,,) = pool.slot0();
        uint256 feeGrowthGlobal0X128 = pool.feeGrowthGlobal0X128();
        uint256 feeGrowthGlobal1X128 = pool.feeGrowthGlobal1X128();

        console.log("Fee Growth ZERO After", feeGrowthGlobal0X128);
        console.log("Fee Growth ONE After", feeGrowthGlobal1X128);

        (, , uint256 fg0_A, uint256 fg1_A, ,,,) = pool.ticks(-10);
        (, , uint256 fg0_B, uint256 fg1_B, ,,,) = pool.ticks(10);
        (, , uint256 fg0_C, uint256 fg1_C, ,,,) = pool.ticks(20);
        (, , uint256 fg0_D, uint256 fg1_D, ,,,) = pool.ticks(40);

        console.log("FG_A", fg0_A, fg1_A);
        console.log("FG_B", fg0_B, fg1_B);
        console.log("FG_C", fg0_C, fg1_C);
        console.log("FG_D", fg0_D, fg1_D);

        // Infomration about position
        bytes32 position = keccak256(abi.encodePacked(address(this), int24(10), int24(20)));

        (uint128 liquidity,,uint256 feeGrowthInside1LastX128,,uint128 tokens1) = pool.positions(position);
        //console.log("liquidity", liquidity);
        //console.log("Fee Last", feeGrowthInside1LastX128);
        //console.log("Tokens 1", tokens1);

        pool.burn(10,20,1*10**8);


        (uint128 liquidityA,,uint256 feeGrowthInside1LastX128A,,uint128 tokens1A) = pool.positions(position);
        //console.log("liquidity", liquidityA);
        //console.log("Fee Last", feeGrowthInside1LastX128A);
        //console.log("Tokens1Owned", tokens1A);

        pool.burn(10,20,1*10**8);

        (uint128 liquidityB,,uint256 feeGrowthInside1LastX128B,,uint128 tokens1B) = pool.positions(position);
       // console.log("liquidity", liquidityB);
        //console.log("Fee Last", feeGrowthInside1LastX128B);
        // console.log("Tokens1Owned", tokens1B);


    }


    function testFeeGrowThree() public {


        uint256 feeGrowthBefore = pool.feeGrowthGlobal1X128();
        console.log("FEE GROWTH BEFORE", feeGrowthBefore);

        (uint amount0A, uint amount1A) = pool.mint(address(this),0,10,10**8,"");
        (uint amount0B, uint amount1B) = pool.mint(address(this),0,20,2*10**8,"");


        // zero for one
        (int amount0swap, int amount1swap) = pool.swap(address(this), false, 200_000, 779625275426524698543654961152, "");
        //console.log(amount0swap);
        //console.log(amount1swap);

        (uint160 sqrtPriceX96, int24 tick, , ,,,) = pool.slot0();
        console.log("FINAL TICK", tick);
    //     uint256 feeGrowthGlobal0X128 = pool.feeGrowthGlobal0X128();
    //     uint256 feeGrowthGlobal1X128 = pool.feeGrowthGlobal1X128();

    //     console.log("Fee Growth ZERO After", feeGrowthGlobal0X128);
    //     console.log("Fee Growth ONE After", feeGrowthGlobal1X128);

    //     (, , uint256 fg0_A, uint256 fg1_A, ,,,) = pool.ticks(-10);
         (, , uint256 fg0_B, uint256 fg1_B, ,,,) = pool.ticks(10);
    //     (, , uint256 fg0_C, uint256 fg1_C, ,,,) = pool.ticks(20);
    //     (, , uint256 fg0_D, uint256 fg1_D, ,,,) = pool.ticks(40);

    //     console.log("FG_A", fg0_A, fg1_A);
         console.log("FG_B", fg0_B, fg1_B);
    //     console.log("FG_C", fg0_C, fg1_C);
    //     console.log("FG_D", fg0_D, fg1_D);

    //     // Infomration about position
    //     bytes32 position = keccak256(abi.encodePacked(address(this), int24(10), int24(20)));

    //     (uint128 liquidity,,uint256 feeGrowthInside1LastX128,,uint128 tokens1) = pool.positions(position);
    //     //console.log("liquidity", liquidity);
    //     //console.log("Fee Last", feeGrowthInside1LastX128);
    //     //console.log("Tokens 1", tokens1);


        // Infomration about position
        bytes32 position = keccak256(abi.encodePacked(address(this), int24(0), int24(10)));

        (uint128 liquidityB,,uint256 feeGrowthInside1LastX128B,,uint128 tokens1B) = pool.positions(position);
        console.log("liquidity Before", liquidityB);
        console.log("Fee Last Before", feeGrowthInside1LastX128B);
        console.log("Tokens 1 Before", tokens1B);


        pool.burn(0,10,0.5 * 10**8);


        // Infomration about position
        // bytes32 position = keccak256(abi.encodePacked(address(this), int24(0), int24(10)));

        (uint128 liquidity,,uint256 feeGrowthInside1LastX128,,uint128 tokens1) = pool.positions(position);
        console.log("liquidity", liquidity);
        console.log("Fee Last", feeGrowthInside1LastX128);
        console.log("Tokens 1", tokens1);

        pool.collect(address(this),0,10,0,25035);

        (uint128 liquidityC,,uint256 feeGrowthInside1LastX128C,,uint128 tokens1C) = pool.positions(position);
        console.log("liquidity C", liquidityC);
        console.log("Fee Last C", feeGrowthInside1LastX128C);
        console.log("Tokens 1 C", tokens1C);



    //     (uint128 liquidityA,,uint256 feeGrowthInside1LastX128A,,uint128 tokens1A) = pool.positions(position);
    //     //console.log("liquidity", liquidityA);
    //     //console.log("Fee Last", feeGrowthInside1LastX128A);
    //     //console.log("Tokens1Owned", tokens1A);

    //     pool.burn(10,20,1*10**8);

    //     (uint128 liquidityB,,uint256 feeGrowthInside1LastX128B,,uint128 tokens1B) = pool.positions(position);
    //    // console.log("liquidity", liquidityB);
    //     //console.log("Fee Last", feeGrowthInside1LastX128B);
    //     // console.log("Tokens1Owned", tokens1B);


    }




    function testFeeGrowTwo() public {

        (uint amount0A, uint amount1A) = pool.mint(address(this),-10,10,10**8,"");
        (uint amount0B, uint amount1B) = pool.mint(address(this),10,20,2*10**8,"");
        (uint amount0C, uint amount1C) = pool.mint(address(this),20,40,3*10**8,"");


        // zero for one
        pool.swap(address(this), false, 300_000, 779625275426524698543654961152, "");
        pool.swap(address(this), true, 260_000, 79228162514264337, "");


        (uint160 sqrtPriceX96, int24 tick, , ,,,) = pool.slot0();
        uint256 feeGrowthGlobal0X128 = pool.feeGrowthGlobal0X128();
        uint256 feeGrowthGlobal1X128 = pool.feeGrowthGlobal1X128();

        console.log("Fee Groth 0", feeGrowthGlobal0X128);
        console.log("Fee Groth 1", feeGrowthGlobal1X128);

        (, , uint256 fg0_A, uint256 fg1_A, ,,,) = pool.ticks(-10);
        (, , uint256 fg0_B, uint256 fg1_B, ,,,) = pool.ticks(10);
        (, , uint256 fg0_C, uint256 fg1_C, ,,,) = pool.ticks(20);
        (, , uint256 fg0_D, uint256 fg1_D, ,,,) = pool.ticks(40);

        console.log("FG_A", fg0_A, fg1_A);
        console.log("FG_B", fg0_B, fg1_B);
        console.log("FG_C", fg0_C, fg1_C);
        console.log("FG_D", fg0_D, fg1_D);

        // Infomration about position
        // bytes32 position = keccak256(abi.encodePacked(address(this), int24(10), int24(20)));

        // (uint128 liquidity,,uint256 feeGrowthInside1LastX128,,uint128 tokens1) = pool.positions(position);
        // console.log("liquidity", liquidity);
        // console.log("Fee Last", feeGrowthInside1LastX128);
        // console.log("Tokens 1", tokens1);

        // pool.burn(10,20,2*10**8);


        // (uint128 liquidityA,,uint256 feeGrowthInside1LastX128A,,uint128 tokens1A) = pool.positions(position);
        // console.log("liquidity", liquidityA);
        // console.log("Fee Last", feeGrowthInside1LastX128A);
        // console.log("Tokens 1", tokens1A);
        

    }


    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
        require(msg.sender == address(pool));
        (Token token0, Token token1) = address(tokenA) < address(tokenB) ? 
            (tokenA, tokenB) :
            (tokenB, tokenA);


        if (amount0Delta > 0) {
            token0.transfer(address(pool),uint(amount0Delta));
        } 
        if (amount1Delta > 0) {
            token1.transfer(address(pool),uint(amount1Delta));
        }
    }


    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external {
        require(msg.sender == address(pool));
        (Token token0, Token token1) = address(tokenA) < address(tokenB) ? 
            (tokenA, tokenB) :
            (tokenB, tokenA);


        if (amount0Owed > 0) {
            token0.transfer(address(pool),amount0Owed);
        } 
        if (amount1Owed > 0) {
            token1.transfer(address(pool),amount1Owed);
        }
    }

    

}