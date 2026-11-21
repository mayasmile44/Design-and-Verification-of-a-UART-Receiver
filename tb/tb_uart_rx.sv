
`timescale 1ns/1ps

module tb_uart_rx;

    localparam integer CLKS_PER_BIT = 16;

    reg clk = 1'b0;
    reg rst = 1'b1;
    reg rx  = 1'b1;

    wire [7:0] data_out;
    wire data_valid;

    integer pass_count = 0;
    integer fail_count = 0;

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(data_out),
        .data_valid(data_valid)
    );

    // 100 MHz clock
    always #5 clk = ~clk;


    // Send one UART byte: 1 start + 8 data + 1 stop
    task send_byte(input [7:0] value);

        integer i;
        integer stop_cycle;
        reg valid_seen;

        begin
            valid_seen = 1'b0;

            $display("\n[%0t] Sending byte: 0x%02h",
                     $time, value);

            // Start bit
            @(negedge clk);
            rx = 1'b0;

            repeat (CLKS_PER_BIT)
                @(negedge clk);

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = value[i];

                repeat (CLKS_PER_BIT)
                    @(negedge clk);
            end

            // Stop bit
            rx = 1'b1;

            // Monitor data_valid throughout the stop bit.
            // Do not wait until the stop bit finishes:
            // data_valid is only a one-clock pulse.
            for (stop_cycle = 0;
                 stop_cycle < CLKS_PER_BIT;
                 stop_cycle = stop_cycle + 1) begin

                @(negedge clk);

                if (data_valid === 1'b1)
                    valid_seen = 1'b1;

            end

            // Verify received data
            if (valid_seen && data_out === value) begin

                $display("PASS: Expected = 0x%02h, Received = 0x%02h",
                         value, data_out);

                pass_count = pass_count + 1;

            end
            else begin

                $display("FAIL: Expected = 0x%02h, Received = 0x%02h, valid_seen=%b",
                         value, data_out, valid_seen);

                fail_count = fail_count + 1;

            end

            // RX remains HIGH during the idle period.
            // The next byte starts on the next negedge.
        end

    endtask


    // Main test sequence
    initial begin

        $dumpfile("build/uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        $display("--------------------------------");
        $display(" UART RX TESTBENCH STARTED");
        $display("--------------------------------");

        // Reset
        repeat (5) @(negedge clk);
        rst = 1'b0;

        repeat (3) @(negedge clk);

        // Test cases
        send_byte(8'hA5);
        send_byte(8'h3C);
        send_byte(8'h00);
        send_byte(8'hFF);

        // Display results
        $display("\n--------------------------------");
        $display("Tests passed : %0d", pass_count);
        $display("Tests failed : %0d", fail_count);
        $display("--------------------------------");

        if (fail_count != 0)
            $fatal(1, "UART RX VERIFICATION FAILED");

        $display("UART RX VERIFICATION PASSED");

        $finish;

    end


    // Global timeout
    initial begin
        #100000;
        $fatal(1, "GLOBAL TIMEOUT!");
    end

endmodule
