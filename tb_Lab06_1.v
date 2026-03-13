`timescale 1ns/1ps

module tb_ARM_CPU;

    // ---- clock / reset ----
    reg clk;
    reg rst_n;

    // ---- declare loop index at module scope (ModelSim 要求) ----
    integer i;

    // instantiate DUT (module name must match your design)
    // 假設你把之前 skeleton 存為 ARM_CPU_simple
    ARM_CPU dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // ---- clock generator ----
    initial begin
        //clk = 0;
        forever #5 clk = ~clk; // 10 ns period
    end

    // ---- waveform dump ----
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ARM_CPU);
    end



    // ---- test init ----
    initial begin
        // initial reset asserted
        rst_n = 1;
        force clk = 1'b0;
        // small delay to allow simulator to start
        #20;

        rst_n = 1'b0;
        #30; rst_n = 1'b1;
        #30;
        release clk;

        // ------------------------------
        // 1) clear memories (inst + data) and RF if accessible
        // ------------------------------
        // note: these hierarchical writes assume dut.IM / dut.DM exist and are reg arrays
        for (i = 0; i < 4096; i = i + 1) begin
            dut.IM[i] = 32'h00000000;
            dut.DM[i] = 32'h00000000;
        end

        // initialize register file to zero first (but leave SP later)
        for (i = 0; i < 16; i = i + 1) begin
            dut.RF[i] = 32'h00000000;
        end

        // ------------------------------
        // 2) load instruction memory:
        //    Option A: use $readmemh if you have IM.hex
        //    Option B: assign a few words manually here (example)
        // ------------------------------
        // Example: if you have IM.hex, uncomment:
        // $readmemh("IM.hex", dut.IM);

        // If you do not have file, you can paste the machine code words:
        // dut.IM[0] = 32'hE92D4800;
        // dut.IM[1] = 32'hE28DB004;
        // ... (fill all words or use readmemh)

        // ------------------------------
        // 3) initialize data memory: literal pool and array
        //    Based on your objdump: .word 0x0000011c at byte addr 0x118
        // ------------------------------
        // place literal pool entry at byte address 0x118 -> word index = 0x118/4 = 0x46
        dut.DM[32'h118 >> 2] = 32'h0000011c;

        // place array starting at 0x11c (word index 0x11c/4 = 0x47)
        // sample array contents given earlier
        dut.DM[(32'h11c >> 2) + 0] = 32'd323;
        dut.DM[(32'h11c >> 2) + 1] = 32'd123;
        dut.DM[(32'h11c >> 2) + 2] = -32'sd455;
        dut.DM[(32'h11c >> 2) + 3] = 32'd2;
        dut.DM[(32'h11c >> 2) + 4] = 32'd98;
        dut.DM[(32'h11c >> 2) + 5] = 32'd125;
        dut.DM[(32'h11c >> 2) + 6] = 32'd10;
        dut.DM[(32'h11c >> 2) + 7] = 32'd65;
        dut.DM[(32'h11c >> 2) + 8] = -32'sd56;
        dut.DM[(32'h11c >> 2) + 9] = 32'd0;

        // ------------------------------
        // 4) initialize stack pointer (SP = r13)
        //    choose a safe stack top (byte address), e.g. 0x400
        // ------------------------------
        dut.RF[0] <= 32'h0;
        dut.RF[1] <= 32'h0;
        dut.RF[2] <= 32'h0;
        dut.RF[3] <= 32'h0;
        dut.RF[4] <= 32'h0;
        dut.RF[5] <= 32'h0;
        dut.RF[6] <= 32'h0;
        dut.RF[7] <= 32'h0;
        dut.RF[8] <= 32'h0;
        dut.RF[9] <= 32'h0;
        dut.RF[10] <= 32'h0;
        dut.RF[11] <= 32'h1F8;
        dut.RF[12] <= 32'h0;
        dut.RF[13] <= 32'h1FC; 
        dut.RF[14] = 32'h11c; // SP*/
        dut.RF[15] <= 32'h0;

        // keep reset asserted for a little while after memory is ready
        #40;
        rst_n = 1;
        
        if(dut.PC == 69)
            $finish;
        else
        // run simulation for a while
        #200000;

        $display("Simulation finished at time %0t", $time);
        

    end

reg [31:0] prev_RF [0:15];
    reg [31:0] prev_DM [0:127];

    //integer i;
    always @(posedge clk) begin

        if (rst_n) begin

            // heartbeat（確認模擬有在跑）
            $display("time=%0t  PC=%0d", $time, dut.PC);

            // -------- RF --------
            for (i=0;i<16;i=i+1) begin
                if (dut.RF[i] !== prev_RF[i]) begin
                    $display("   RF[%0d]  %08h  ->  %08h",
                             i,
                             $signed(prev_RF[i]),
                             $signed(dut.RF[i]));
                    prev_RF[i] = dut.RF[i];
                end
            end

            // -------- DM --------
            for (i=0;i<128;i=i+1) begin
                if (dut.DM[i] !== prev_DM[i]) begin
                    $display("   DM[%0d]  %08h  ->  %08h",
                             i,
                             $signed(prev_DM[i]),
                             $signed(dut.DM[i]));
                    prev_DM[i] = dut.DM[i];
                end
            end

        end

    end

    // --- optional monitor ---
    initial begin
        #100;
        $display("Time  PC    R3      SP");
        forever begin
            #500;
            $display("%0t  %0d  0x%08h  0x%08h", $time, dut.PC, dut.RF[3], dut.RF[13]);
        end
    end

endmodule