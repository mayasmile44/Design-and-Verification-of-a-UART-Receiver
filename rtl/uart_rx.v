`timescale 1ns/1ps

module uart_rx #(
    parameter integer CLKS_PER_BIT = 5208
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output reg  [7:0] data_out,
    output reg        data_valid
);

    localparam [1:0] IDLE      = 2'd0;
    localparam [1:0] START_BIT = 2'd1;
    localparam [1:0] DATA_BITS = 2'd2;
    localparam [1:0] STOP_BIT  = 2'd3;

    reg [1:0] state;
    integer clk_count;
    reg [2:0] bit_index;
    reg [7:0] rx_shift;

    always @(posedge clk) begin
        if (rst) begin
            state      <= IDLE;
            clk_count  <= 0;
            bit_index  <= 0;
            rx_shift   <= 8'd0;
            data_out   <= 8'd0;
            data_valid <= 1'b0;
        end 
	    else begin
            data_valid <= 1'b0;

            case (state)
                IDLE: begin
                    clk_count <= 0;
                    bit_index <= 0;
                    if (rx == 1'b0)
                        state <= START_BIT;
                end

                START_BIT: begin
                    if (clk_count == (CLKS_PER_BIT/2 - 1)) begin
                        clk_count <= 0;
                        if (rx == 1'b0)
                            state <= DATA_BITS;
                        else
                            state <= IDLE;
                    end 
			else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DATA_BITS: begin
                    if (clk_count == (CLKS_PER_BIT - 1)) begin
                        clk_count <= 0;
                        rx_shift[bit_index] <= rx;
                        if (bit_index == 3'd7) begin
                            bit_index <= 0;
                            state <= STOP_BIT;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                STOP_BIT: begin
                    if (clk_count == (CLKS_PER_BIT - 1)) begin
                        clk_count <= 0;
                        if (rx == 1'b1) begin
                            data_out   <= rx_shift;
                            data_valid <= 1'b1;
                        end
                        state <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                default: begin
                    state <= IDLE;
                    clk_count <= 0;
                end
            endcase
        end
    end

endmodule
