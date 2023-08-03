import BlockDist.Block;

// declare configurable constants with default values
config const nx = 4096,     // number of grid points in x
             nt = 100,      // number of time steps
             alpha = 0.25;  // diffusion constant

// define distributed domains to describe the grid and its interior
const omega = Block.createDomain({0..<nx}),
      omegaHat = omega.expand(-1);

// define an array over the above domain
var u : [omega] real;

// set up initial conditions
u = 1.0;
u[nx/4..3*nx/4] = 2;

// create a temporary copy of 'u' to store the previous time step
var un = u;

// iterate for 'nt' time steps
for 1..nt {
  // swap arrays to prepare for next time step
  u <=> un;

  // update the solution over the interior of the domain in parallel
  forall i in omegaHat do
    u[i] = un[i] + alpha * (un[i-1] - 2 * un[i] + un[i+1]);
}

// print final results
const mean = (+ reduce u) / u.size,
      stdDev = sqrt((+ reduce (u - mean)**2) / u.size);
writeln("mean: ", mean, " stdDev: ", stdDev);
