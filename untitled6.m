%% (0) 初始化
field_init(-1);                    % 随机种子；-1 为使用 CPU
fs = 80e6; c = 1500;               % 采样频率 & 声速
set_field('fs', fs); set_field('c', c);

%% (1) 定义换能器/阵列
N = 32; f0 = 300e3;                % 32 阵元、中心频率 300 kHz
lambda = c/f0; pitch = lambda/2;   % 元间距（半波长）
width = pitch*0.9; element_h = 0.01;
kerf = pitch - width;              % 间隙

xdc = xdc_linear_array( ...
      N, width, element_h, kerf, 1, 1, [0 0 0]);  % 发/收用同一阵元对象

%% (2) 设定激励与换能器脉冲响应
t_imp = (0:4/f0)/fs;               % 4 周期 Hanning
impulse = sin(2*pi*f0*t_imp) .* hanning(numel(t_imp))';
xdc_impulse(xdc, impulse);         % Tx & Rx 默认一致

t_exc = (0:1/f0)/fs;               % 1 周期正弦激励
excitation = sin(2*pi*f0*t_exc);
xdc_excitation(xdc, excitation);

%% (3) 构造散射场/目标
pos = [0 0 1.0]';  amp = 1;        % 单点目标, 1 m 距离

%% (4) 计算通道级 pulse-echo 回波
[rf, t0] = calc_hp(xdc, xdc, pos, amp); % rf: [Nsamp × N_elem]

%% (5) 后处理（可选）
% 例如在 USTB 中封装：channel_data.data = rf;

%% (6) 清理内存
xdc_free(xdc);
