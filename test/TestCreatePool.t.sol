pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/UniswapV3Factory.sol"; 
import "../src/UniswapV3Pool.sol";
import "../src/Token.sol";

contract FactoryTest is Test {

    UniswapV3Factory factory;
    UniswapV3Pool pool;
    Token tokenA;
    Token tokenB;

    function computePoolAddress(
        address _tokenA,
        address _tokenB,
        uint24 fee
    ) public view returns (address) {
        (address token0, address token1) = _tokenA < _tokenB
            ? (_tokenA, _tokenB)
            : (_tokenB, _tokenA);

        bytes32 salt = keccak256(abi.encode(token0, token1, fee));

        bytes32 initCodeHash = keccak256(type(UniswapV3Pool).creationCode);

        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(factory), 
                salt,
                initCodeHash
            )
        );

        return address(uint160(uint256(hash)));
    }

    function setUp() public {
        tokenA = new Token("Token A", "TKA");
        tokenB = new Token("Token B", "TKB");
    }

    function testDeployFactory() public {
        // let us test if we can deploy the factory contract
        factory = new UniswapV3Factory();
        int24 tickSpacingFor500 = factory.feeAmountTickSpacing(500);
        assertEq(tickSpacingFor500, 10);
    }

    function testSetNewFeeTier() public {
         factory = new UniswapV3Factory();   
         factory.enableFeeAmount(2000,50);
        int24 tickSpacingFor2000 = factory.feeAmountTickSpacing(2000);
        assertEq(tickSpacingFor2000, 50);
    }

    function testCorrectAddressGeneration() public {
        factory = new UniswapV3Factory();

        address calculatedAddress = computePoolAddress(address(tokenA), address(tokenB), 500);
        address realAddress = factory.createPool(address(tokenA), address(tokenB), 500);

        assertEq(calculatedAddress, realAddress);
    }

    function testCorrectFee() public {
        factory = new UniswapV3Factory();

        address pool = factory.createPool(address(tokenA), address(tokenB), 500);

        uint24 fee = UniswapV3Pool(pool).fee();
        int24 tickSpacing = UniswapV3Pool(pool).tickSpacing();

        uint128 maxLiquidityPerTick = UniswapV3Pool(pool).maxLiquidityPerTick();
        
        assertEq(fee,500);
        assertEq(tickSpacing, 10);
        // write a test to check maxLiquidityPerTick

    }

    function testInitializePool() public {
        factory = new UniswapV3Factory();
        pool = UniswapV3Pool(factory.createPool(address(tokenA), address(tokenB), 500));

        uint160 initialPrice = 2**96; 
        
        pool.initialize(initialPrice);
        (,int24 tick,,) = pool.slot0();
        assertEq(tick, 0);

    }

    

}