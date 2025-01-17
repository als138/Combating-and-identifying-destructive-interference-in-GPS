function probeData(varargin)
%Function plots raw data information: time domain plot, a frequency domain
%plot and a histogram.
%
%The function can be called in two ways:
%   probeData(settings)
% or
%   probeData(fileName, settings)
%
%   Inputs:
%       fileName        - name of the data file. File name is read from
%                       settings if parameter fileName is not provided.
%
%       settings        - receiver settings. Type of data file, sampling
%                       frequency and the default filename are specified
%                       here.

%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
%
% Copyright (C) Dennis M. Akos
% Written by Darius Plausinaitis and Dennis M. Akos
%--------------------------------------------------------------------------
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
%USA.
%--------------------------------------------------------------------------
% CVS record:
% $Id: probeData.m,v 1.1.2.7 2006/08/22 13:46:00 dpl Exp $
% _________________________________________________________________________

%% Check the number of arguments ==========================================
if (nargin == 1)
    settings = deal(varargin{1});
    fileNameStr = settings.fileName;
elseif (nargin == 2)
    [fileNameStr, settings] = deal(varargin{1:2});
    if ~ischar(fileNameStr)
        error('File name must be a string');
    end
else
    error('Incorect number of arguments');
end

%% Generate plot of raw data ==============================================
[fid, message] = fopen(fileNameStr, 'rb');

if (fid > 0)
    
    if (settings.fileType==1)
        dataAdaptCoeff=1;
    else
        dataAdaptCoeff=2;
    end
    
    % Move the starting point of processing. Can be used to start the
    % signal processing at any point in the data record (e.g. for long
    % records).
    fseek(fid, dataAdaptCoeff*settings.skipNumberOfBytes, 'bof');
    
    % Find number of samples per spreading code
    samplesPerCode = round(settings.samplingFreq / ...
        (settings.codeFreqBasis / settings.codeLength));
    
    if (settings.fileType==1)
        dataAdaptCoeff=1;
    else
        dataAdaptCoeff=2;
    end
    
    % Read 100ms of signal
    [data, count] = fread(fid, [1, dataAdaptCoeff*100*samplesPerCode], settings.dataType);
    
    fclose(fid);
    
    if strcmp(settings.dataType, 'uchar')
        data = data - 127;
    end
    
    if (count < dataAdaptCoeff*100*samplesPerCode)
        % The file is to short
        error('Could not read enough data from the data file.');
    end
    
    %--- Initialization ---------------------------------------------------
    figure(100);
    clf(100);
    
    timeScale = 0 : 1/settings.samplingFreq : 5e-3;
    
    %--- Time domain plot -------------------------------------------------
    if (settings.fileType==1)
        
        %subplot(2, 1, 1);
        plot(1000 * timeScale(1:round(samplesPerCode/50)), ...
            data(1:round(samplesPerCode/50)));
        
        axis tight;    grid on;
        title ('Time domain plot');
        xlabel('Time (ms)'); ylabel('Amplitude');
    else
        
        data=data(1:2:end) + 1i .* data(2:2:end);
        subplot(2, 1, 1);
        plot(1000 * timeScale(1:round(samplesPerCode/50)), ...
            real(data(1:round(samplesPerCode/50))),'Color',[0.4940 0.1840 0.5560]);
        
        axis tight;    grid on;
        title ('Time domain plot (I)');
        xlabel('Time (ms)'); ylabel('Amplitude');
        
        subplot(2, 1, 2);
        plot(1000 * timeScale(1:round(samplesPerCode/50)), ...
            imag(data(1:round(samplesPerCode/50))),'Color',[0.8500 0.3250 0.0980]);
        
        axis tight;    grid on;
        title ('Time domain plot (Q)');
        xlabel('Time (ms)'); ylabel('Amplitude');
        
    end
    
    figure(101);
    clf(101);
    %--- Frequency domain plot --------------------------------------------
    
    if (settings.fileType==1) %Real Data
        subplot(2,2,1:2);
        pwelch(data, 32758, 2048, 16368, settings.samplingFreq/1e6)
    else % I/Q Data
        subplot(4,2,1:2);
        [sigspec,freqv]=pwelch(data, 32758, 2048, 16368, settings.samplingFreq,'twosided');
        plot(([-(freqv(length(freqv)/2:-1:1));freqv(1:length(freqv)/2)])/1e6, ...
            10*log10([sigspec(length(freqv)/2+1:end);
            sigspec(1:length(freqv)/2)]),'Color',[0.5,0,0.5]);
    end
    
    axis tight;
    grid on;
    title ('Frequency domain plot');
    xlabel('Frequency (MHz)'); ylabel('Magnitude');
    
    %--- Histogram --------------------------------------------------------
    
    if (settings.fileType == 1)
        subplot(2, 2, 4);
        hist(data, -128:128)
        
        dmax = max(abs(data)) + 1;
        axis tight;     adata = axis;
        axis([-dmax dmax adata(3) adata(4)]);
        grid on;        title ('Histogram');
        xlabel('Bin');  ylabel('Number in bin');
    else
        subplot(4, 2, 4);
        hist(real(data), -128:128);
        dmax = max(abs(data)) + 1;
        axis tight;     adata = axis;
        axis([-dmax dmax adata(3) adata(4)]);
        grid on;        title ('Histogram (I)');
        xlabel('Bin');  ylabel('Number in bin');
        
        subplot(4, 2, 3);
        hist(imag(data), -128:128)
        dmax = max(abs(data)) + 1;
        axis tight;     adata = axis;
        axis([-dmax dmax adata(3) adata(4)]);
        grid on;        title ('Histogram (Q)');
        xlabel('Bin');  ylabel('Number in bin');
        
        % magnitude of signal
        subplot(4, 2, 6);
        hist(abs(data), 0:1:ceil(max(abs(data))))
        dmax = max(abs(data)) + 1;
        axis tight;     adata = axis;
        axis([0 dmax adata(3) adata(4)]);
        grid on;        title ('Histogram magnitude');
        xlabel('Bin');  ylabel('Number in bin');
        
        % phase of signal
        subplot(4, 2, 5);
        hist(angle(data), -3.14:0.1:3.14)
        dmax = pi;
        axis tight;     adata = axis;
        axis([-dmax dmax adata(3) adata(4)]);
        grid on;        title ('Histogram angle');
        xlabel('Bin');  ylabel('Number in bin');
        
        % iq waveform
        subplot(4, 2, 8);
        plot(data); hold all; plot(data,'rd');
        grid on;        title ('Raw I/Q Data');
        xlabel('I');  ylabel('Q');
        
        
        % real waveform
        subplot(4, 2, 7);
        plot(real(data(1:1000)));
        grid on;        title ('Real Waveform');
        xlabel('sample');  ylabel('Re');
        
    end
else
    %=== Error while opening the data file ================================
    error('Unable to read file %s: %s.', fileNameStr, message);
end % if (fid > 0)
