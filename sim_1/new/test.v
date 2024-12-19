module tb_traffic_light_controller;

    // 测试bench信号定义
    reg clk;                  // 时钟信号
    reg reset;                // 重置信号
    reg manual_override;      // 外部手动控制信号
    reg [1:0] manual_state;   // 外部手动控制的状态（00-红灯, 01-黄灯, 10-绿灯）
    wire R;                   // 红灯输出
    wire G;                   // 绿灯输出
    wire [3:0] time_remaining; // 剩余时间
    wire [7:0] seg;           // 七段显示器输出

    // 实例化 traffic_light_controller
    traffic_light_controller uut (
        .clk(clk),
        .reset(reset),
        .manual_override(manual_override),
        .manual_state(manual_state),
        .R(R),
        .G(G),
        .time_remaining(time_remaining),
        .seg(seg)  // 连接七段显示器输出
    );

    // 时钟生成
    always begin
        #5 clk = ~clk;  // 每5时间单位反转一次时钟信号，时钟周期为10
    end

    // 初始化信号
    initial begin
        // 初始化信号
        clk = 0;
        reset = 0;
        manual_override = 0;
        manual_state = 2'b00;  // 默认红灯

        // 测试流程

        // 1. 重置
        #10 reset = 1;   // 在10个时间单位后激活复位
        #10 reset = 0;   // 10个时间单位后取消复位

        // 2. 自动模式（自动切换红、黄、绿灯）
        #500;
        $display("Auto Mode: R = %b, G = %b, time_remaining = %d, seg = %b", R, G, time_remaining, seg);

        // 3. 手动控制模式
        #200;
        manual_override = 1;  // 激活手动控制
        manual_state = 2'b01; // 设置为黄灯
        #200;
        $display("Manual Mode (Yellow): R = %b, G = %b, time_remaining = %d, seg = %b", R, G, time_remaining, seg);

        manual_state = 2'b10; // 设置为绿灯
        #200;
        $display("Manual Mode (Green): R = %b, G = %b, time_remaining = %d, seg = %b", R, G, time_remaining, seg);

        manual_state = 2'b00; // 设置为红灯
        #200;
        $display("Manual Mode (Red): R = %b, G = %b, time_remaining = %d, seg = %b", R, G, time_remaining, seg);

        manual_override = 0;  // 取消手动控制
        #500;
        $display("Auto Mode Resumed: R = %b, G = %b, time_remaining = %d, seg = %b", R, G, time_remaining, seg);

        $finish;  // 结束仿真
    end

    // 显示信号变化（可选）
    initial begin
        $monitor("At time %t, R = %b, G = %b, time_remaining = %d, seg = %b, manual_override = %b, manual_state = %b", 
                  $time, R, G, time_remaining, seg, manual_override, manual_state);
    end

endmodule
