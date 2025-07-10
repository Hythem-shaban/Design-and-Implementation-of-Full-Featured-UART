# Design and Implementation of Full-Featured UART
This is a design of a fully configured uart transmitter and receiver using Verilog-HDL and implemented in DE10-Lite Max-10 FPGA Dev board.

This project allows customization of key UART parameters such as parity, stop bits, data bits, and baud rate — providing a robust UART interface suitable for various serial communication applications.

---

## Motivation
A universal asynchronous receiver and transmitter (UART) is a circuit that sends parallel data through a serial line. UARTs are frequently used in conjunction with the EIA (Electronic Industries Alliance) RS-232 standard, which specifies the electrical, mechanical, functional, and procedural characteristics of two data communication equipment.

A UART includes a transmitter and a receiver. The transmitter is essentially a special shift register that loads data in parallel and then shifts it out bit by bit at a specific rate. The receiver, on the other hand, shifts in data bit by bit and then reassembles the data. 
The serial line is 1 when it is idle. The transmission starts with a start bit, which is 0, followed by data bits and an optional parity bit, and ends with stop bits, which are 1. The number of data bits can be 6, 7, or 8. The optional parity bit is used for error detection. For odd parity, it is set to 0 when the data bits have an odd number of I 's. For even parity, it is set to 0 when the data bits have an even number of 1 's. The number of stop bits can be 1, 1.5, or 2.

![Alt Text](/doc/frame.svg)



No clock information is conveyed through the serial line. Before the transmission starts, the transmitter and receiver must agree on a set of parameters in advance, which include the baud rate (i.e., number of bits per second), the number of data bits and stop bits, and use of the parity bit. 

The block diagram of the UART Tx and Rx is shown below:
![Alt Text](/doc/arch.svg)

Because the voltage level defined in RS-232 is different from that of FPGA I/O, a voltage converter chip is needed between a serial port and an FPGA's I/O pins.
The DE10-Lite board does not have an RS232 port so, we have used FT232RL USB TO TTL 3.3V/5V FTDI Serial Adapter Module.
![alt text](/doc/FT232RL.png)

---

## Features

✅ **Configurable Parity**:
- No Parity  
- Even Parity  
- Odd Parity  

✅ **Selectable Stop Bits**:
- 1 Stop Bit  
- 2 Stop Bits  

✅ **Selectable Data Bits**:
- 7 Data Bits  
- 8 Data Bits  

✅ **Selectable Baud Rate**:
- 1200 bps  
- 2400 bps  
- 4800 bps  
- 9600 bps  

✅ **FIFO Buffers**:
- Internal TX and RX FIFOs to handle burst data  
- Prevents data loss due to overflow or timing mismatch  

✅ **Error Detection**:
- Parity Error  
- Framing Error 

---

## Configurable Interface

This UART design allows dynamic runtime configuration and data entry using only **10 switches** and **2 push buttons** on the **DE10-Lite FPGA**. A demultiplexing scheme enables the same switches to be used for both configuration and data input.

---

### Switch and Button Overview

| Component | Function |
|-----------|----------|
| **SW0–SW7** | Shared: UART Configuration or TX Data Input (based on `SW9`) |
| **SW8**     | **Active-Low Reset** |
| **SW9**     | **Mode Selector**: `0` = Config Mode, `1` = Data Mode |
| **KEY0**    | **TX FIFO Write Enable** – triggers sending data in TX mode |
| **KEY1**    | **RX FIFO Read Enable** – triggers reading received data |

---

### Mode Selector – `SW9`

| `SW9` Value | Mode            | SW0–SW7 Purpose        |
|-------------|------------------|------------------------|
| `0`         | Configuration Mode | Configure UART settings |
| `1`         | Data Entry Mode    | Enter data to transmit |

---

### Configuration Mapping (When `SW9 = 0`)

In **Configuration Mode**, the switches are interpreted as follows:

| Switch | Signal Name     | Description |
|--------|------------------|-------------|
| SW1–SW0 | `baud_sel[1:0]` | Selects baud rate |
| SW2    | `stop_bits`     | 0 = 1 stop bit, 1 = 2 stop bits |
| SW3    | `data_bits`     | 0 = 7 bits, 1 = 8 bits |
| SW5–SW4 | `parity[1:0]`   | 00 = None, 01 = Even, 10 = Odd |
| SW6–SW7 | Reserved / Future Use |

#### Baud Rate Options (`baud_sel[1:0]`)
| Value | Baud Rate |
|-------|-----------|
| 00    | 1200 bps  |
| 01    | 2400 bps  |
| 10    | 4800 bps  |
| 11    | 9600 bps  |

#### Data Bits (`data_bits`)
| Value | Bits |
|-------|------|
| 0     | 7    |
| 1     | 8    |

#### Stop Bits (`stop_bits`)
| Value | Bits |
|-------|------|
| 0     | 1    |
| 1     | 2    |

#### Parity (`parity[1:0]`)
| Value | Mode        |
|-------|-------------|
| 00    | None        |
| 01    | Even Parity |
| 10    | Odd Parity  |
| 11    | Reserved    |

---

### Control Buttons

| Button | Signal | Description |
|--------|--------|-------------|
| `KEY0` | `wr_en_tx_fifo` | Push to **write TX data** (from SW0–SW7) into TX FIFO |
| `KEY1` | `rd_en_rx_fifo` | Push to **read received data** from RX FIFO |

Both are **active-low** (default behavior on DE10-Lite). Debouncing is recommended in hardware or logic if needed.

---

### Reset – `SW8`

- Active **LOW** system reset.
- When `SW8 = 0`, the UART and both FIFOs are reset and cleared.

---

### Example Use Case

1. **Enter Config Mode**: Set `SW9 = 0`  
2. Set SW0–SW5 for desired UART config (e.g., parity, stop bits, etc.)  
3. Return to **Data Mode**: Set `SW9 = 1`  
4. Set SW0–SW7 to the data byte to transmit  
5. Press `KEY0` to write the byte to TX FIFO  
6. On receive, press `KEY1` to read data from RX FIFO


This compact interface design fully utilizes the limited I/Os on the DE10-Lite, enabling real-time UART testing and debugging with full control over transmission and reception.

---

## Hardware Setup & Connection

### PC ↔ FPGA UART Wiring

To connect the UART module to a PC:

| FPGA Pin (from your UART design) | Connects To           |
|----------------------------------|------------------------|
| `tx` (UART transmitter output)   | FTDI RX (PC receive)   |
| `rx` (UART receiver input)       | FTDI TX (PC transmit)  |
| `GND`                            | FTDI GND / PC GND      |

> Use a terminal emulator (e.g., PuTTY, Tera Term, or RealTerm) on your PC and match the settings (baud rate, parity, stop bits, etc.) with your UART configuration on the FPGA.

---

## Simulation
### Setup
This project includes a testbench and a ready-made `run.do` script to simplify simulation using **Questa Simulator** (QuestaSim).
#### How to Simulate
1. **Navigate to the `tb/` directory**:
   ```bash
    cd tb
   ```
2. **Run the simulation script**:
    ```bash
    vsim -do run_uart.do
    ```
    - The `run_uart.do` script handles:
      1. Compiling all design and testbench files
      2. Loading the top-level testbench
      3. Launching the simulation with waveform display

### Waveform Snipits
A snipit of transmitting and receiving 8-bit data with baud rate 1200, one stop bit, and no parity:
![Alt Text](/doc/wave1_d8_s1_br1200_p0.svg)

A snipit of transmitting and receiving 8-bit data with baud rate 2400, two stop bits, and even parity:
![Alt Text](/doc/wave2_d8_s2_br2400_pe.svg)

A snipit of transmitting and receiving 8-bit data with baud rate 4800, two stop bits, and odd parity:
![Alt Text](/doc/wave3_d8_s2_br4800_po.svg)

A snipit of transmitting and receiving 7-bit data with baud rate 9600, two stop bits, and no parity:
![Alt Text](/doc/wave4_d7_s2_br9600_p0.svg)

---

## FPGA Implementation
### Setup
This project is implemented using **Quartus Prime Lite** on **DE10-lite Board**.
#### Steps:
1. Open Quartus and create a new project.
2. Add all files from the rtl/ directory and from syn/ directory
3. Set the top-level entity as top.
4. Configure pins according to DE10-Lite constraints.
5. Compile the design and program the board.

#### Block Diagram:
![Alt Text](/doc/block.svg)

#### RTL Viewer:
![Alt Text](/doc/rtl_viewer.png)

#### Pin Planner:
A snipit of the pin planner window. You can find the `.qsf` in `syn/` in which the pin assigment is done.
![Alt Text](/doc/pinplanner.png)

### Demo

- inputs
![Alt Text](/doc/inputs.jpg)
- outputs
![Alt Text](/doc/outputs.jpg)

You can find the demo from this link:
[Demo](https://drive.google.com/file/d/1UZsq-8KFqmJnLGoAjSMQWqmU2z_bPd4W/view?usp=sharing)


---

# License
This project is licensed under the [MIT License](/LICENSE).


