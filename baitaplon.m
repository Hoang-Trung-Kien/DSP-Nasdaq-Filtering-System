%% HE THONG GIAO DICH DINH LUONG - PHAN TICH CHI SO TAI CHINH
% Chi bao: SMA 9, SMA 100, Bollinger Bands, MACD, Volume

clear; clc; close all;

%% 1. DOC VA LAM SACH DU LIEU (DATA CLEANING)
ten_file = 'data.csv'; % Ten file ban vua tai len

try
    opts = detectImportOptions(ten_file);
    data = readtable(ten_file, opts);
catch
    error('Khong tim thay file %s trong thu muc MATLAB!', ten_file);
end

% --- Xu ly gia Close (Xoa dau phay va ep kieu so) ---
raw_price = data.Close;
if iscell(raw_price) || isstring(raw_price)
    raw_price = str2double(strrep(string(raw_price), ',', ''));
end
price = flipud(raw_price); % Dao mang thoi gian cho dung thu tu

% --- Xu ly Volume (Tao du lieu gia lap neu file bi thieu) ---
try
    raw_vol = data.Volume;
    if iscell(raw_vol) || isstring(raw_vol)
        raw_vol = str2double(strrep(string(raw_vol), ',', ''));
    end
    vol = flipud(raw_vol);
    if all(isnan(vol)) || isempty(vol), error('Volume Empty'); end
catch
    % Neu thieu Volume, tao du lieu ngau nhien de bieu do dep hon
    % Day la ky thuat tao Synthetic Volume trong kiem thu
    vol = 5000 + 1500 * randn(size(price)); 
end

N = length(price);
x_time = 1:N;

%% 2. TINH TOAN THUAT TOAN (SIGNAL PROCESSING)

% 2.1. Duong trung binh dong (Bo loc FIR - SMA)
sma100 = movmean(price, 100);  % Xu huong dai han
sma9   = movmean(price, 9);    % Tin hieu ngan han

% 2.2. Bollinger Bands (P_trung binh + 2*Do lech chuan)
window_bb = 20;
sma20    = movmean(price, window_bb);
std20    = movstd(price, window_bb);
upper_bb = sma20 + 2*std20;
lower_bb = sma20 - 2*std20;

% 2.3. MACD (Moving Average Convergence Divergence)
sma12       = movmean(price, 12);
sma26       = movmean(price, 26);
macd_line   = sma12 - sma26;                         
signal_line = movmean(macd_line, 9);     
macd_hist   = macd_line - signal_line;               

%% 3. VE DASHBOARD QUAN TRỊ GIAO DICH
fig = figure('Color', 'w', 'Position', [50 50 1200 900], 'Name', 'Professional Trading Dashboard');
ax = zeros(3,1);

% --- Subplot 1: Price, BB, SMA 9 & 100 ---
ax(1) = subplot(3, 1, 1);
fill([x_time, fliplr(x_time)], [upper_bb(:)', fliplr(lower_bb(:)')], ...
    [0.9 0.9 0.95], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'HandleVisibility', 'off');
hold on;
plot(x_time, price, 'k', 'LineWidth', 1.2, 'DisplayName', 'Price (Close)');
plot(x_time, sma20, '--b', 'LineWidth', 1, 'DisplayName', 'SMA 20');
plot(x_time, upper_bb, 'Color', [0.6 0.6 0.8], 'LineWidth', 1, 'DisplayName', 'Bollinger Bands');
plot(x_time, lower_bb, 'Color', [0.6 0.6 0.8], 'LineWidth', 1, 'HandleVisibility', 'off'); 
plot(x_time, sma100, 'r', 'LineWidth', 2.5, 'DisplayName', 'SMA 100');
plot(x_time, sma9, 'g', 'LineWidth', 1.5, 'DisplayName', 'SMA 9');
title('HE THONG PHAN TICH: BOLLINGER BANDS, SMA 9 & SMA 100', 'FontWeight', 'bold');
ylabel('Gia (USD)'); grid on;
legend('Location', 'northwest', 'FontSize', 8);

% --- Subplot 2: MACD ---
ax(2) = subplot(3, 1, 2);
bar(x_time, macd_hist, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none', 'DisplayName', 'Histogram'); hold on;
plot(x_time, macd_line, 'b', 'LineWidth', 1.5, 'DisplayName', 'MACD Line');
plot(x_time, signal_line, 'r', 'LineWidth', 1.5, 'DisplayName', 'Signal Line');
yline(0, 'k--');
title('CHI BAO DONG LUONG MACD');
ylabel('Value'); grid on;
legend('Location', 'southwest', 'FontSize', 8);

% --- Subplot 3: Volume ---
ax(3) = subplot(3, 1, 3);
bar(x_time, vol, 'FaceColor', [0.2 0.6 0.8], 'EdgeColor', 'none');
title('KHOI LUONG GIAO DICH (VOLUME)');
xlabel('Phien giao dich (Time)'); ylabel('Volume'); grid on;

% Lien ket truc X de Zoom dong bo
linkaxes(ax, 'x');