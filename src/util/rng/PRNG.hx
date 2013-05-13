package util.rng;

import util.TypeDefs;

/**
 * Implementation of the Park Miller (1988) "minimal standard" linear
 * congruential pseudo-random number generator.
 *
 * For a full explanation visit: http://www.firstpr.com.au/dsp/rand31/
 *
 * The generator uses a modulus constant (m) of 2^31 - 1 which is a
 * Mersenne Prime number and a full-period-multiplier of 16807.
 * Output is a 31 bit unsigned integer. The range of values output is
 * 1 to 2,147,483,646 (2^31-1) and the seed must be in this range too.
 *
 * David G. Carta's optimisation which needs only 32 bit integer math,
 * and no division is actually *slower* in flash (both AS2 & AS3) so
 * it's better to use the double-precision floating point version.
 *
 * @author Michael Baczynski, www.polygonal.de
 */
class PM_PRNG
{
    /**
     * set seed with a 31 bit unsigned integer
     * between 1 and 0X7FFFFFFE inclusive. don't use 0!
     */
    public var seed:UInt;

    public function new( _seed:UInt = 1 )
    {
        seed = _seed;
    }

    /**
     * provides the next pseudorandom number
     * as an unsigned integer (31 bits)
     */
    public function nextInt():UInt
    {
        return gen();
    }

    /**
     * provides the next pseudorandom number
     * as a float between nearly 0 and nearly 1.0.
     */
    public function nextDouble():Float
    {
        return ( gen() / 2147483647 );
    }

    /**
     * provides the next pseudorandom number
     * as an unsigned integer (31 bits) betweeen
     * a given range.
     */
    public function nextIntRange( min:Float, max:Float ):UInt
    {
        min -= .4999;
        max += .4999;
        return Math.round( min + (( max - min ) * nextDouble()));
    }

    /**
     * provides the next pseudorandom number
     * as a float between a given range.
     */
    public function nextDoubleRange( min:Float, max:Float ):Float
    {
        return min + (( max - min ) * nextDouble());
    }

    /**
     * generator:
     * new-value = (old-value * 16807) mod (2^31 - 1)
     */
    private function gen():UInt
    {
        //integer version 1, for max int 2^46 - 1 or larger.
        return seed = ( seed * 16807 ) % 2147483647;
    }
}