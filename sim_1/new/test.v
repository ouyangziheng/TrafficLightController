module traffic_light_controller_tb;

// 测试信号定义
reg clk;
reg reset;
reg manual_override;
reg [1:0] manual_state;
wire R;
wire G;
wire [3:0] time_remaining;
wire [7:0] seg;

// 生成 100 MHz 时钟
always begin
    clk = 0;
    #5 clk = 1; 
end

// 实例化 traffic_light_controller 模块
traffic_light_controller uut (
    .clk(clk),
    .reset(reset),
    .manual_override(manual_override),
    .manual_state(manual_state),
    .R(R),
    .G(G),
    .time_remaining(time_remaining),
    .seg(seg)
    .scan_select(scan_select)
);

// 初始测试
initial begin
    // 初始值
    reset = 0;
    manual_override = 0;
    manual_state = 2'b00;  // 默认为红灯

    // 模拟复位过程
    #10 reset = 1;  // 触发复位
    #10 reset = 0;  // 取消复位

    // 测试自动状态切换（正常模式）
    #20000;  // 等待 200ns（即 0.2 秒），然后观察状态变化
    
    // 激活手动控制
    #100 manual_override = 1;
    manual_state = 2'b01;  // 设置为黄灯状态
    #10000;  // 保持黄灯 1 秒
    
    manual_state = 2'b10;  // 设置为绿灯状态
    #10000;  // 保持绿灯 1 秒
    
    manual_state = 2'b00;  // 设置为红灯状态
    #10000;  // 保持红灯 1 秒
    
    // 停止手动控制
    #10 manual_override = 0;
    
    // 等待自动状态切换
    #3000000;  // 总共 3 秒，观察是否自动切换

    // 停止仿真
    $stop;
end

// 打印输出信号，方便观察
initial begin
    $monitor("Time: %t | R: %b | G: %b | time_remaining: %d | seg: %b", 
             $time, R, G, time_remaining, seg);
end

endmodule
