function data = ReadRawData(varargin)

    % This is a "default" name of the data file (signal record) to be used in
    % the post-processing mode

    % 120s sample worked!
    fileName = varargin{1};
     
    skipNumberOfBytes     = 0; 
    dataType              = 'schar';        % uchar, schar = 1 byte
    fileType              = 2;              % 2 = IQ, 1 = Real
    %dataSize             = 1;              % bytes
    %IF                   = 0;              % [Hz]
    samplingFreq          = 10e6;           % [Hz]
    rec_len = varargin{2};                            % [ms]

    % File Types
    %1 - 8 bit real samples S0,S1,S2,...
    %2 - 8 bit I/Q samples I0,Q0,I1,Q1,I2,Q2,...
    codeFreqBasis      = 1.023e6;      %[Hz]
    % Define number of chips in a code period
    codeLength         = 1023;
    

[fid, message] = fopen(fileName, 'rb');

%Initialize the multiplier to adjust for the data type
if (fileType==1) 
    dataAdaptCoeff=1;
else
    dataAdaptCoeff=2;
end

%If success, then process the data
if (fid > 0)
    % Move the starting point of processing. Can be used to start the
    % signal processing at any point in the data record (e.g. good for long
    % records or for signal processing in blocks).
    fseek(fid, dataAdaptCoeff*skipNumberOfBytes, 'bof');
    % Find number of samples per spreading code
        samplesPerCode = round(samplingFreq / ...
                           (codeFreqBasis / codeLength));
     % Read data for acquisition. 11ms of signal are needed for the fine
        % frequency estimation (10ms CA code + padding to start of code)
        
        data = fread(fid, dataAdaptCoeff*rec_len*samplesPerCode, dataType)';
         if strcmp(dataType, 'uchar')
            data = data - 127;
         end
        if (dataAdaptCoeff==2)
            data1=data(1:2:end);    
            data2=data(2:2:end);    
            data=data1 + 1i .* data2;    
        end
else
    % Error while opening the data file.
    error('Unable to read file %s: %s.', settings.fileName, message);
end % if (fid > 0)





end

