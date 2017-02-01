%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to assign wavelength of used carrier according to used GNSS 
% system, measurement type (pseudorange, phase, dopler, SNR) and for
% GLONASS satellites also according to SV number.
%
% Input:  GNSS - character for GNSS type (e.g. 'E');
%         type - 3-character identifier of measurement (e.g. 'C1C')
%         SV   - nx1 array of satellite's numbers (only for GLONASS)
%                (e.g. [1, 5, 12])
%
% Output: lam  - size of carrier wavelength in meters
%              - scalar for GPS, Galileo, Beidou, array nx1 for GLONASS
%
% Revision: 1.2.2017, Peter Spanik, spanikp@yahoo.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lam = wavelength(GNSS, type, SV)

c = 299792458;
switch GNSS
    
    %%%%% GPS SYSTEM
    case 'G'
       switch type(2)
           case '1'
               f = 1575.42e6;   % GPS L1
           case '2'
               f = 1227.60e6;   % GPS L2
           case '5'
               f = 1176.45e6;   % GPS L5
           otherwise
               error(['There is no ', type, ' measurement defined for GPS in RINEX !!!']);
       end  
       
    %%%%%% GLONASS SYSTEM   
    case 'R'
       if isempty(SV)
          error('For GLONASS system satellite number have to be specified !!!') 
       end
       
       FCH = [1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24
              1  -4   5   6   1  -4   5   6  -6  -7   0  -1  -2  -7   0  -1   4  -3   3   2   4  -3   3   2]; 
       
       switch type(2)
           case '1'
               f0 = 1602e6;      % GLONASS G1 (FDMA)
               Df = 562.5e3;
           case '2'
               f0 = 1246e6;      % GLONASS G2 (FDMA)
               Df = 437.5e3;
           case '3'        
               f0 = 1202.025e6;  % GLONASS G3 (CDMA) 
               Df = 0;
           otherwise
               error(['There is no ', type, ' measurement defined for GLONASS in RINEX !!!']);
       end
       
       CHN = NaN(size(SV));
       for i = 1:length(SV)
           CHN(i) = FCH(2,SV(i) == FCH(1,:));
       end
       
       f = f0 + Df*CHN;
       
    %%%%% GALILEO SYSTEM   
    case 'E'
       switch type(2)
           case '1'
               f = 1575.420e6;   % GALILEO E1
           case '5'
               f = 1176.450e6;   % GALILEO E5a
           case '7'
               f = 1207.140e6;   % GALILEO E5b
           case '8'
               f = 1191.795e6;   % GALILEO E5 (E5a+E5b)
           case '6'
               f = 1278.750e6;   % GALILEO E6
           otherwise
               error(['There is no ', type, ' measurement defined for Galileo in RINEX !!!']);
       end 
       
    %%%%% BEIDOU SYSTEM   
    case 'C'
       switch type(2)
           case '1'
               f = 1561.098e6;   % BEIDOU B1
           case '2'
               f = 1207.140e6;   % BEIDOU B2
           case '3'
               f = 1268.520e6;   % BEIDOU B3
           otherwise
               error(['There is no ', type, ' measurement defined for Beidou in RINEX !!!']);
       end 
       
    %%%%% SBAS SYSTEM   
    case 'S'
        
       switch type(2)
           case '1'
               f = 1575.42e6;    % L1
           case '5'
               f =  1176.45e6;   % L5
           otherwise
               error(['There is no ', type, ' measurement defined for SBAS in RINEX !!!']);
       end 
       
    otherwise
        error(['There is no GNSS system for ', GNSS, ' character !!!']);
       
end

lam = c./f;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
