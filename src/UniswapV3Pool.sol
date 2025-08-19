// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {IUniswapV3PoolDeployer} from "./interfaces/IUniswapV3PoolDeployer.sol";
import {Tick} from "./libraries/Tick.sol";
import {TickMath} from "./libraries/TickMath.sol";
import {Position} from "./libraries/Position.sol";
import {IERC20Minimal} from './interfaces/IERC20Minimal.sol';
import {IUniswapV3MintCallback} from './interfaces/callback/IUniswapV3MintCallback.sol';
import {SafeCast} from "./libraries/SafeCast.sol";
import {LowGasSafeMath} from "./libraries/LowGasSafeMath.sol";
import {SqrtPriceMath} from "./libraries/SqrtPriceMath.sol";


contract UniswapV3Pool {

    // Declare we are going to use a library in some type
    using LowGasSafeMath for int256;
   using LowGasSafeMath for uint256;

    
    event Initialize(uint160 sqrtPriceX96, int24 tick);
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

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

   function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1) {

        // This function will calculate how many tokens0 and/or tokens1
        // the user should transfer
        require(amount > 0);
        (, int256 amount0Int, int256 amount1Int) =
            _modifyPosition(
                ModifyPositionParams({
                    owner: recipient,
                    tickLower: tickLower,
                    tickUpper: tickUpper,
                    liquidityDelta: int128(amount)
                })
            );

        amount0 = uint256(amount0Int);
        amount1 = uint256(amount1Int);

        uint256 balance0Before;
        uint256 balance1Before;
        if (amount0 > 0) balance0Before = balance0();
        if (amount1 > 0) balance1Before = balance1();
        IUniswapV3MintCallback(msg.sender).uniswapV3MintCallback(amount0, amount1, data);
        if (amount0 > 0) require(balance0Before.add(amount0) <= balance0(), 'M0');
        if (amount1 > 0) require(balance1Before.add(amount1) <= balance1(), 'M1');

        emit Mint(msg.sender, recipient, tickLower, tickUpper, amount, amount0, amount1);

    }

        struct ModifyPositionParams {
        // the address that owns the position
        address owner;
        // the lower and upper tick of the position
        int24 tickLower;
        int24 tickUpper;
        // any change in liquidity
        int128 liquidityDelta;
    }

    function _modifyPosition(ModifyPositionParams memory params)
        private
        returns (
            Position.Info storage position,
            int256 amount0,
            int256 amount1
        )
    {

        checkTicks(params.tickLower, params.tickUpper);

        Slot0 memory _slot0 = slot0;
 
        // Calculate the amount0 and amount1
        if (params.liquidityDelta != 0) {
            // 3 cases
            // 1 current tick below lower tick
            if (_slot0.tick < params.tickLower) {
                // calculate amount0
                amount0 = SqrtPriceMath.getAmount0Delta(
                    TickMath.getSqrtRatioAtTick(params.tickLower), 
                    TickMath.getSqrtRatioAtTick(params.tickUpper),
                    params.liquidityDelta);
            } else if (_slot0.tick < params.tickUpper) {
                // calculate amount0
                amount0 = SqrtPriceMath.getAmount0Delta(
                    TickMath.getSqrtRatioAtTick(_slot0.tick), 
                    TickMath.getSqrtRatioAtTick(params.tickUpper),
                    params.liquidityDelta);
                // calculate amount1
                amount1 = SqrtPriceMath.getAmount1Delta(
                    TickMath.getSqrtRatioAtTick(params.tickLower), 
                    TickMath.getSqrtRatioAtTick(_slot0.tick),
                    params.liquidityDelta);
                // update liquidity
                
            } else {
                // calculate amount1
                    amount1 = SqrtPriceMath.getAmount1Delta(
                    TickMath.getSqrtRatioAtTick(params.tickLower), 
                    TickMath.getSqrtRatioAtTick(params.tickUpper),
                    params.liquidityDelta);

            }
        }

        // Update the position, ticks
        // The protocol will call a function named _updatePosition



        return (positions[0x00],100,100);
    }

 function balance0() private view returns (uint256) {
        (bool success, bytes memory data) =
            token0.staticcall(abi.encodeWithSelector(IERC20Minimal.balanceOf.selector, address(this)));
        require(success && data.length >= 32);
        return abi.decode(data, (uint256));
    }

    /// @dev Get the pool's balance of token1
    /// @dev This function is gas optimized to avoid a redundant extcodesize check in addition to the returndatasize
    /// check
    function balance1() private view returns (uint256) {
        (bool success, bytes memory data) =
            token1.staticcall(abi.encodeWithSelector(IERC20Minimal.balanceOf.selector, address(this)));
        require(success && data.length >= 32);
        return abi.decode(data, (uint256));
    }

   function checkTicks(int24 tickLower, int24 tickUpper) private pure {
        require(tickLower < tickUpper, 'TLU');
        require(tickLower >= TickMath.MIN_TICK, 'TLM');
        require(tickUpper <= TickMath.MAX_TICK, 'TUM');
    }

}