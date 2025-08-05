// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {IUniswapV3PoolDeployer} from "./interfaces/IUniswapV3PoolDeployer.sol";
import {Tick} from "./libraries/Tick.sol";
import {TickMath} from "./libraries/TickMath.sol";
import {Position} from "./libraries/Position.sol";


contract UniswapV3Pool {
    
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    address public immutable factory;
    address public immutable token0;
    address public immutable token1;
    uint24 public immutable fee;
    int24 public immutable tickSpacing;
    uint128 public immutable maxLiquidityPerTick;

    struct Slot0 {
        uint160 sqrtPriceX96;
        int24 tick;
        uint8 feeProtocol;
        bool unlocked;
    }

    Slot0 public slot0;

    uint256 public feeGrowthGlobal0X128;
    uint256 public feeGrowthGlobal1X128;

    struct ProtocolFees {
        uint128 token0;
        uint128 token1;
    }
   
    ProtocolFees public protocolFees;

    uint128 public liquidity;

    mapping(int24 => Tick.Info) public ticks;
    mapping(int16 => uint256) public tickBitmap;
    mapping(bytes32 => Position.Info) public positions;


    constructor() {

        int24 _tickSpacing;
        (factory, token0, token1, fee, _tickSpacing) = IUniswapV3PoolDeployer(msg.sender).parameters();
        tickSpacing = _tickSpacing;

        maxLiquidityPerTick = Tick.tickSpacingToMaxLiquidityPerTick(_tickSpacing);
      
    }

    function initialize(uint160 sqrtPriceX96) external {

        // require it is not itialized
        require(slot0.sqrtPriceX96 == 0, "AI");

        // Get the tick corresponding with the price
        int24 tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);

        // Initialize slot0
        slot0 = Slot0({
            sqrtPriceX96: sqrtPriceX96,
            tick: tick,
            feeProtocol: 0,
            unlocked: true
        });

        // Emit an event
        emit Initialize(sqrtPriceX96, tick);
    }

}