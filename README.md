# Smart Traffic Light Controller (FSM-Based)

A 4-way smart traffic light controller designed using a Moore FSM in SystemVerilog. It includes:

- 🚦 Timed Green/Yellow/Red logic for N-S-E-W directions  
- 🚶‍♂️ Pedestrian override: All RED on request  
- 🚑 Emergency vehicle priority: Immediate green to incoming direction  
- ✅ Synthesizable, testbench-verified, and easy to extend for FPGA

## 🧠 FSM States

| State            | Meaning             |
|------------------|---------------------|
| N_GREEN, N_YELLOW | North traffic       |
| S_GREEN, S_YELLOW | South traffic       |
| E_GREEN, E_YELLOW | East traffic        |
| W_GREEN, W_YELLOW | West traffic        |
| ALL_RED_PEDESTRIAN | Pedestrian cross   |
| *_EMERGENCY       | Emergency handling  |

## 📂 Files

| File                  | Description                      |
|-----------------------|----------------------------------|
| `traffic_control.sv`  | RTL design (FSM)                 |
| `tb_traffic_control.sv`| Testbench with waveform & print |
| `docs/`               | Block diagrams, explanations     |

## 📸 Simulation Outputs

### 🧠 FSM Waveform
Shows the FSM behavior across time with transitions between green/yellow/red lights:

![FSM Waveform](docs/waveform.png)

---

### 🚶 Pedestrian Override Output

Console output when pedestrian request is triggered:

![Pedestrian Console](docs/pedestrian.png)

---

### 🚑 Emergency Vehicle Priority Output

Console debug output when an emergency vehicle is detected:

![Emergency Vehicle Console](docs/emergencyvehicle.png)
