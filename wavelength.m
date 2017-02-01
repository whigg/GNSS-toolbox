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
% References: RINEX The Receiver Independent Exchange Format, Version 3.02
%             IGS RINEX WG & RTCM-SC104. Table2 - Table 7
%
% Revision: 1.2.2017, Peter Spanik, email: spanikp@yahoo.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lam = wavelength(GNSS, type, SV)

if isempty(strfind('CLSD',type(1)))
   error(['There is no ', type, ' measurement defined in RINEX !!!']); 
end

c = 2.99792458e8;
switch GNSS
    
    %%%%% GPS SYSTEM
    case 'G'
       switch type(2)
           case '1'   % GPS L1
               if isempty(strfind('CSLXPWYMN',type(3))) || strcmp(type,'C1N')
                  error(['There is no ', type, ' measurement defined in RINEX for GPS L1 band !!!']); 
               end
               f = 1575.42e6;
               
           case '2'   % GPS L2
               if isempty(strfind('CDSLXPWYMN',type(3))) || strcmp(type,'C2N')
                  error(['There is no ', type, ' measurement defined in RINEX for GPS L2 band !!!']); 
               end
               f = 1227.60e6;
               
           case '5'   % GPS L5
               if isempty(strfind('IQX',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for GPS L5 band !!!']); 
               end
               f = 1176.45e6;
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
           case '1'   % GLONASS G1 (FDMA)
               if isempty(strfind('CP',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for GLONASS G1 band !!!']); 
               end
               f0 = 1602e6;
               Df = 562.5e3;
               
           case '2'   % GLONASS G2 (FDMA)
               if isempty(strfind('CP',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for GLONASS G2 band !!!']); 
               end
               f0 = 1246e6;
               Df = 437.5e3;
               
           case '3'   % GLONASS G3 (CDMA) 
               if isempty(strfind('IQX',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for GLONASS G3 band !!!']); 
               end
               f0 = 1202.025e6;
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
           case '1'   % GALILEO E1
               if isempty(strfind('ABCXZ',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for Galileo E1 band !!!']); 
               end
               f = 1575.420e6;
               
           case '5'   % GALILEO E5a
               if isempty(strfind('IQX',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for Galileo E5a band !!!']); 
               end
               f = 1176.450e6;
               
           case '7'   % GALILEO E5b
               if isempty(strfind('IQX',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for Galileo E5b band !!!']); 
               end
               f = 1207.140e6;
               
           case '8'   % GALILEO E5 (E5a+E5b)
               if isempty(strfind('IQX',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for Galileo E5(E5a+E5b) band !!!']); 
               end
               f = 1191.795e6;
               
           case '6'   % GALILEO E6
               if isempty(strfind('ABCXZ',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for Galileo E6 band !!!']); 
               end
               f = 1278.750e6;
           otherwise
               error(['There is no ', type, ' measurement defined for Galileo in RINEX !!!']);
       end 
       
    %%%%% BEIDOU SYSTEM   
    case 'C'
       switch type(2)
           case '1'   % BEIDOU B1
               if isempty(strfind('IQX',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for Beidou B1 band !!!']); 
               end
               f = 1561.098e6;
               
           case '2'   % BEIDOU B2
               if isempty(strfind('IQX',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for Beidou B2 band !!!']); 
               end
               f = 1207.140e6;
               
           case '3'   % BEIDOU B3
               if isempty(strfind('IQX',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for Beidou B3 band !!!']); 
               end
               f = 1268.520e6;
           otherwise
               error(['There is no ', type, ' measurement defined for Beidou in RINEX !!!']);
       end 
       
    %%%%% SBAS SYSTEM   
    case 'S'
       switch type(2)
           case '1'    % L1
               if strcmp('C',type(3))
                  error(['There is no ', type, ' measurement defined in RINEX for SBAS L1 band !!!']); 
               end
               f = 1575.42e6;
               
           case '5'   % L5
               if isempty(strfind('IQX',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for SBAS L5 band !!!']); 
               end
               f =  1176.45e6;
           otherwise
               error(['There is no ', type, ' measurement defined for SBAS in RINEX !!!']);
       end 

    %%%%% QZSS SYSTEM   
    case 'J'
       switch type(2)
           case '1'    % QZSS L1
               if isempty(strfind('CSLXZ',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for QZSS L1 band !!!']); 
               end
               f = 1575.42e6;
               
           case '2'    % QZSS L2
               if isempty(strfind('SLX',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for QZSS L2 band !!!']); 
               end
               f = 1227.60e6;
               
           case '5'   % QZSS L5
               if isempty(strfind('IQX',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for QZSS L5 band !!!']); 
               end
               f =  1176.45e6;
               
           case '6'   % QZSS LEX(6)
               if isempty(strfind('SLX',type(3)))
                  error(['There is no ', type, ' measurement defined in RINEX for QZSS LEX(6) band !!!']); 
               end
               f =  1278.75e6;
           otherwise
               error(['There is no ', type, ' measurement defined for QZSS in RINEX !!!']);
       end 
       
    otherwise
        error(['There is no GNSS system for ', GNSS, ' character !!!']);
       
end

lam = c./f;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
