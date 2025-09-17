pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/UniswapV3Factory.sol"; 
import "../src/UniswapV3Pool.sol";
import "../src/Token.sol";
import "../src/interfaces/callback/IUniswapV3MintCallback.sol";
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

    }

    function testMintPosition() public {
        uint160 initialPrice = 4295128740;
        pool.initialize(initialPrice);

        (uint amount0, uint amount1) = pool.mint(address(this),-10,10,10**9,"");
        console.log(amount0);
        console.log(amount1);
        // Let us grab the ticks
        (uint128 grossLower, int128 netLower, , , ) = pool.ticks(-10);
        (uint128 grossUpper, int128 netUpper, , , ) = pool.ticks(10);
        
        console.log("grossLower", grossLower); // 10**6
        console.log("grossUpper", grossUpper); // 10**6
        console.log("netLower", netLower); // 10**6
        console.log("netUpper", netUpper); // - 10**6

    }

    function testMintTwoPosition() public {
        pool.mint(address(this),-10,10,200,"");
        pool.mint(address(this),0,20,100,"");
        // Let us grab the ticks
        (uint128 grossLower, int128 netLower, , , ) = pool.ticks(-10);
        (uint128 grossMiddle, int128 netMiddle, , , ) = pool.ticks(0);
        (uint128 grossUpper, int128 netUpper, , , ) = pool.ticks(10);

    }

    function testTickBitmap() public {
        pool.mint(address(this),-100,200,2000000,"");
        // current tick is tick 0
        // what is the next initialized tick less than current tick
        // and greater than current tick?
        (int24 tick, bool initialized) = pool.checkNextInitializedTick(0, false);
        console.log(tick);
        console.log(initialized);
    }

    function testAnotherMint() public {
        uint160 initialPrice = 79228162514264337593543950336;
        pool.initialize(initialPrice);

        (uint amount0, uint amount1) = pool.mint(address(this),10,20,10**9,"");
        console.log(amount0);
        console.log(amount1);
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