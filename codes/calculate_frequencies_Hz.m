function fre = calculate_frequencies_Hz()
% Author: Mingqiang Han
% Date: September 10, 2024
%
% Description:
% This function calculates a set of frequencies in Hz based on 
% three different index ranges. The function generates 1110 
% frequency values, where:
%   - For i <= 10, frequencies are calculated as 100 * i.
%   - For 10 < i <= 110, frequencies are calculated using 
%                        a logarithmic scale from 1000 Hz.
%   - For i > 110, frequencies are calculated using a logarithmic scale 
%     from 1 MHz (1e6 Hz).
%
% Outputs:
%   fre - (array) A 1x1110 array containing the calculated frequencies.

% Define the size of the frequency array (1110 frequency points)
fre_size = 1110;

% Create a vector for indices from 1 to 1110
i = 1:fre_size;

% Preallocate the frequency array with zeros
fre = zeros(1, fre_size);

% Assign values to the frequency array based on index ranges

% For i <= 10, calculate frequencies as 100 * i
fre(i <= 10) = 100 * i(i <= 10);

% For 10 < i <= 110, use a logarithmic scale starting from 1000 Hz
fre(i > 10 & i <= 110) = 10.^(0.03 * (i(i > 10 & i <= 110) - 10)) * 1000;

% For i > 110, use a logarithmic scale starting from 1 MHz (1e6 Hz)
fre(i > 110) = 10.^(0.003 * (i(i > 110) - 110)) * 1000000;

end
