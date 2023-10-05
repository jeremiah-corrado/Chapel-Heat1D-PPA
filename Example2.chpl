import Collectives.barrier;

// declare configurable constants with default values
config const nx = 4096,     // number of grid points in x
             nt = 100,      // number of time steps
             alpha = 0.25;  // diffusion constant

// set the number of tasks equal to the number of available cores
const nTasks = here.maxTaskPar,
      npt = nx / nTasks;

// define a domain to describe the grid
const omega = {0..<nx},
      omegaHat = omega.expand(-1);

// define an array over the above domain
var u : [omega] real;

// set up initial conditions
u = 1.0;
u[nx/4..3*nx/4] = 2.0;

// define array of halo cells for each side of each task
var halos : [0..<nTasks] [0..1] real;
param LEFT = 0, RIGHT = 1;

// set up a global barrier for the number of tasks
var b = new barrier(nTasks);

// run the simulation across tasks
coforall tid in 0..<nTasks do taskSimulate(tid);

// print final results
const mean = (+ reduce u) / u.size,
      stdDev = sqrt((+ reduce (u - mean)**2) / u.size);
writeln("mean: ", mean, " stdDev: ", stdDev);

proc taskSimulate(tid: int) {
  // define region of the global array owned by this task
  const lo = tid * npt,
        hi = min((tid + 1) * npt, nx);

  const omegaLocal = {lo..<hi},
        omegaLocalBuffered = omegaLocal.expand(1),
        omegaLocalHat = omegaLocal[omegaHat];

  // create local arrays
  var uLocal1, uLocal2: [omegaLocalBuffered] real = 1.0;

  // load global initial conditions into local arrays
  uLocal1[omegaLocal] = u[omegaLocal];
  uLocal2 = uLocal1;

  // iterate for 'nt' time steps
  for 1..nt {
    // copy results from previous iteration into neighbors' halo cells
    b.barrier();
    if tid != 0        then halos[tid-1][RIGHT] = uLocal2[omegaLocal.low];
    if tid != nTasks-1 then halos[tid+1][LEFT] = uLocal2[omegaLocal.high];

    // swap local arrays
    b.barrier();
    uLocal1 <=> uLocal2;

    // load values from neighbors' halo cells into local array's borders
    if tid != 0        then uLocal1[omegaLocalBuffered.low] = halos[tid][LEFT];
    if tid != nTasks-1 then uLocal1[omegaLocalBuffered.high] = halos[tid][RIGHT];

    // compute the FD kernel in parallel
    for i in omegaLocalHat do
      uLocal2[i] = uLocal1[i] + alpha *
        (uLocal1[i-1] - 2 * uLocal1[i] + uLocal1[i+1]);
  }

  // store this task's results in global array
  b.barrier();
  uLocal1 <=> uLocal2;
  u[omegaLocal] = uLocal1[omegaLocal];
}
