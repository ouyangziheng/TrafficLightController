module tb_traffic_light_controller;

    // 测试bench信号定义
    reg clk;                  // 时钟信号
    reg reset;                // 重置信号
    reg manual_override;      // 外部手动控制信号
    reg [1:0] manual_state;   // 外部手动控制的状态（00-红灯, 01-黄灯, 10-绿灯）
    wire R;                   // 红灯输出
    wire G;                   // 绿灯输出

    // 实例化 traffic_light_controller
    traffic_light_controller uut (
        .clk(clk),
        .reset(reset),
        .manual_override(manual_override),
        .manual_state(manual_state),
        .R(R),
        .G(G)
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

        // 重置
        #10 reset = 1;   // 在10个时间单位后激活复位
        #10 reset = 0;   // 10个时间单位后取消复位
        
        // 自动状态机测试
        #50;              // 等待50个时间单位，让状态机运行
        $display("Auto mode: R = %b, G = %b", R, G);

        // 手动控制测试
        #20;              // 等待20个时间单位
        manual_override = 1;  // 激活手动控制
        manual_state = 2'b01; // 设置为黄灯
        #20;              // 等待20个时间单位查看效果
        $display("Manual mode: R = %b, G = %b", R, G);

        manual_state = 2'b10; // 设置为绿灯
        #20;              // 等待20个时间单位查看效果
        $display("Manual mode: R = %b, G = %b", R, G);

        manual_state = 2'b00; // 设置为红灯
        #20;              // 等待20个时间单位查看效果
        $display("Manual mode: R = %b, G = %b", R, G);
        
        manual_override = 0;  // 取消手动控制
        #50;              // 等待50个时间单位，让状态机恢复自动模式
        $display("Auto mode resumed: R = %b, G = %b", R, G);

        $finish;           // 结束仿真
    end

    // 显示信号变化（可选）
    initial begin
        $monitor("At time %t, R = %b, G = %b, manual_override = %b, manual_state = %b", $time, R, G, manual_override, manual_state);
    end

endmodule
