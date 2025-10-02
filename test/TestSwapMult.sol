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


    function setUp() public {
        tokenA = new Token("Token A", "TKA");
        tokenB = new Token("Token B", "TKB");
        factory = new UniswapV3Factory();
        pool = UniswapV3Pool(factory.createPool(address(tokenA), address(tokenB), 500));

        // tick 0
        uint160 initialPrice = 79228162514264337593543950336;
        pool.initialize(initialPrice);


    }

    function testSwapMultiple() public {

        (uint amount0A, uint amount1A) = pool.mint(address(this),-10,10,10**8,"");
        (uint amount0B, uint amount1B) = pool.mint(address(this),10,20,2*10**8,"");
        (uint amount0C, uint amount1C) = pool.mint(address(this),20,40,3*10**8,"");



        // zero for one
        (int amount0swap, int amount1swap) = pool.swap(address(this), false, 300_000, 779625275426524698543654961152, "");
        console.log(amount0swap);
        console.log(amount1swap);

        (uint160 sqrtPriceX96, int24 tick, , ,,,) = pool.slot0();
        console.log(sqrtPriceX96);
        console.log(tick);

    }


    function testSwapMultipleTwo() public {

        (uint amount0A, uint amount1A) = pool.mint(address(this),-10,10,10**8,"");
        (uint amount0B, uint amount1B) = pool.mint(address(this),10,20,2*10**8,"");
        (uint amount0C, uint amount1C) = pool.mint(address(this),20,40,3*10**8,"");



        // zero for one
        (int amount0swap, int amount1swap) = pool.swap(address(this), false, -300_000, 79167784519130042428790663799, "");
        console.log(amount0swap);
        console.log(amount1swap);

        (uint160 sqrtPriceX96, int24 tick, , ,,,) = pool.slot0();
        console.log(sqrtPriceX96);
        console.log(tick);

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