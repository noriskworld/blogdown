import random
import simpy
import pandas as pd

RANDOM_SEED = 42
MTTF = 100.0                     # Mean time to failure in minutes
REPAIR_TIME = 2.0               # Time it takes to repair a machine in minutes
NUM_MACHINES = 1                  # Number of machines in the machine shop
WEEKS = 4                         # Simulation time in weeks
SIM_TIME = WEEKS * 7 * 24 * 60    # Simulation time in minutes



def simNHPP(end_sim):
    event_log = []
    env = simpy.Environment()
    machine_1 = Machine(env, "Machine_1", event_log)
    machine_2 = Machine(env, "Machine_2", event_log)
    env.run(until = end_sim)
    event_log = pd.DataFrame(event_log, columns = ['event','time'])
    return event_log

def time_to_repair():
    """return time interval until the repair is done, and machine is ready to run again. """
    return REPAIR_TIME

def time_to_failure():
    """Return time until next failure for a machine.""" 
    return random.expovariate(1.0/MTTF)

# each machine has a name, and pass the event_log 
# time to failure and time to repair are defined globally. 
class Machine:
    def __init__(self, env, name, event_log):
        self.env = env
        self.name = str(name)
        self.work_proc = env.process(self.working(env, event_log))

    def working(self, env, event_log):
        while True:
            # Up until failure
            time_to_fail = time_to_failure()
            # print('%s: time to next failure is %.2f' % (self.name, time_to_fail))
            yield env.timeout(time_to_fail)

            # Repair for time_to_repair
            # print("%s Failure Starts at %.2f" % (self.name, env.now))
            event_log.append([self.name + " fails", env.now])
            repair_time = time_to_repair()
            yield env.timeout(repair_time)
            # print("%s is repaired at %.2f" % (self.name, env.now))
            event_log.append([self.name + " fixed", env.now])