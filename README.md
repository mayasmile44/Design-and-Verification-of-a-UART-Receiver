**Design and Verification of a UART Receiver using Verilator and GTKWave**

**Project Overview -** 
- This project implements an 8-bit UART (Universal Asynchronous Receiver/Transmitter) receiver using Verilog HDL.
- The receiver captures serial data through the RX input, identifies the start bit, samples the incoming data bits, validates the stop bit, and provides the received data as an 8-bit parallel output.
- The design is verified using a testbench and simulated using Verilator.

**UART Communication Protocal**

UART is Universal Asynchronous Receiver Transmitter Communication. It is serial communication used to transefer data between Digital devices.

There are Two Data wires :
- TX - Transmits the serial data
- RX - Recevies the data parallely

DATA FRAME FORMAT :

This project implements an 8N1 UART frame format consisting of:
- 1 Start bit
- 8 Data bits (LSB first)
- No parity bit
- 1 Stop bit
The receiver samples the incoming serial data and converts it into 8-bit parallel data.

DESIGN SPECFICATIONS :

| Parameter | Specification |
|---|---|
| Communication Protocol | UART |
| Data Width | 8 bits |
| Start Bit | 1 bit (LOW) |
| Stop Bit | 1 bit (HIGH) |
| Data Transmission | LSB First |
| FSM States | 4 |
| Default Clock Cycles per Bit | 5208 |
| Testbench Clock Cycles per Bit | 16 |
| Output | 8-bit parallel data |
| Data Valid | 1-cycle pulse |

**Receiver Operation -**

The UART receiver consists of four FSM states:

1. IDLE(00) - Waits for the incoming start bit.
2. START_BIT(01) - Detects and validates the start bit.
3. DATA_BITS(10) - Samples the eight incoming data bits.
4. STOP_BIT(11) - Validates the stop bit and updates the output data.

The received byte is stored in an internal shift register before being transferred to the output

**Tools Used -**

- Verilog HDL
- Verilator
- GTKWave
- WSL (Ubuntu)

**Future Improvements -**

- Add a two-flip-flop synchronizer for the asynchronous RX input.
- Add framing error detection.
- Improve verification with additional test scenarios.
- Test the design with different clock-per-bit configurations.

**Project Structure -**

```text
Design-and-Verification-of-a-UART-Receiver/
│
├── rtl/
│   └── uart_rx.v
│
├── tb/
│   └── tb_uart_rx.sv
│
├── waves/
│   └── uart_rx_A5_waveform.png
│
├── README.md
└── .gitignore

