function xtr2MPskyplot(xtrFileName, MPcode, saveFig, options)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to read Gnut-Anubis XTR output file and make MP skyplot graphs.
% Process iterates through all available satellite systems (it will
% detect automatically) and try to plot given MP combination.
%
% Input:
% xtrFileName - name of XTR file
% MPcode - 2-char representation of MP code combination to plot
%        - values corresponding to RINEX v2 code measurements
%
% Optional:
% saveFig - true/false flag to export plots to PNG file (default: true)
% options - {colorBarLimits, colorBarTicks, figureResolution}
%         - default values: colorBarLimits = [0 120];
%                           colorBarTicks = 0:20:120;
%
% Requirements:
% polarplot3d.m, findGNSTypes.m, dataCell2matrix.m, getNoSatZone.m
%
% Peter Spanik, 14.9.2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Close all opened figures
close all

% Check input values
if nargin == 2
   saveFig = true;
   options = {[0, 120], 0:20:120, '200'};
   if ~ischar(xtrFileName) || ~ischar(MPcode)
      error('Inputs "xtrFileName" and "MPcode" have to be strings!') 
   end
   %xtr2MPskyplot('wecafare-VISO.xtr','C1',false,{[0,150],0:50:150},'150')
elseif nargin == 3
    saveFig = logical(saveFig);
   if ~ischar(xtrFileName) || ~ischar(MPcode) || numel(saveFig) ~= 1 
      error('Inputs "xtrFileName","MPcode" have to be strings and "saveFig" has to be single value!') 
   end
   options = {[0, 120], 0:20:120, '200'};
elseif nargin == 4
   if numel(options) ~= 3
      error('Input variable "limAndTicks" have to be cell of the following form {[1x2 array], [1xn array], [1xn char]}!') 
   end
else
   error('Only 2, 3 or 4 input values are allowed!') 
end

% File loading
finp = fopen(xtrFileName,'r');
raw = textscan(finp,'%s','Delimiter','\n','Whitespace','');
data = raw{1,1};

% Find empty lines in XTR file and remove them
data = data(~cellfun(@(c) isempty(c), data));

% Find indices of Main Chapters (#)
GNScell = findGNSTypes(data);

% Set custom colormap -> empty bin = white
myColorMap = colormap(jet); close; % Command colormap open figure!
myColorMap = [[1,1,1]; myColorMap];

% Satellite's data loading
for i = 1:length(GNScell)
    % Find position estimate
    selpos = cellfun(@(c) strcmp(['=XYZ', GNScell{i}],c(1:7)), data);
    postext = char(data(selpos));
    pos = str2num(postext(30:76));
    
    % Elevation loading
    selELE_GNS = cellfun(@(c) strcmp([GNScell{i}, 'ELE'],c(2:7)), data);
    dataCell = data(selELE_GNS);
    [timeStamp, meanVal, dataMatrix] = dataCell2matrix(dataCell);
    ELE.(GNScell{i}).time = timeStamp;
    ELE.(GNScell{i}).meanVals = meanVal;
    ELE.(GNScell{i}).vals = dataMatrix;
    sel1 = ~isnan(dataMatrix);
    
    % Azimuth loading
    selAZI_GNS = cellfun(@(c) strcmp([GNScell{i}, 'AZI'],c(2:7)), data);
    dataCell = data(selAZI_GNS);
    [timeStamp, meanVal, dataMatrix] = dataCell2matrix(dataCell);
    AZI.(GNScell{i}).time = timeStamp;
    AZI.(GNScell{i}).meanVals = meanVal;
    AZI.(GNScell{i}).vals = dataMatrix;
    sel2 = ~isnan(dataMatrix);
    
    % Multipath loading
    selMP_GNS = cellfun(@(c) strcmp([' ', GNScell{i}, 'M', MPcode], c(1:7)), data);
    if nnz(selMP_GNS) == 0
        warning('For %s system MP combination %s not available!',GNScell{i},MPcode)
        continue
    end
    dataCell = data(selMP_GNS);
    [timeStamp, meanVal, dataMatrix] = dataCell2matrix(dataCell);
    MP.(GNScell{i}).time = timeStamp;
    MP.(GNScell{i}).meanVals = meanVal;
    MP.(GNScell{i}).vals = dataMatrix;
    sel3 = ~isnan(dataMatrix);
    
    sel = sel1 & sel2 & sel3;
    ELE.(GNScell{i}).vector = ELE.(GNScell{i}).vals(sel);
    AZI.(GNScell{i}).vector = AZI.(GNScell{i}).vals(sel);
    MP.(GNScell{i}).vector = MP.(GNScell{i}).vals(sel);
    
    % Interpolate to regular grid
    [azig, eleg] = meshgrid(0:3:357, 0:3:90);
    F = scatteredInterpolant(AZI.(GNScell{i}).vector,ELE.(GNScell{i}).vector,MP.(GNScell{i}).vector,'linear','none');
    mpg = F(azig,eleg);
    mpg(isnan(mpg)) = -1;
    
    % Determine noSatZone bins
    [x_edge,y_edge] = getNoSatZone(GNScell{i},pos);
    xq = (90 - eleg).*sind(azig);
    yq = (90 - eleg).*cosd(azig);
    in = inpolygon(xq,yq,x_edge,y_edge);
    mpg(in) = -1;
    
    % Create figure
    figure('Position',[300 100 700 480],'NumberTitle', 'off','Resize','off')
    polarplot3d(flipud(mpg),'PlotType','surfn','RadialRange',[0 90],'PolarGrid',{6,12},'GridStyle',':','AxisLocation','surf');
    view(90,-90)
    
    colormap(myColorMap)
    c = colorbar;
    colLimits = options{1};
    colLimits(1) = colLimits(1) + 5;
    c.Limits = colLimits;
    c.Ticks = options{2};
    c.Position = [c.Position(1)*1.02, c.Position(2)*1.4, 0.8*c.Position(3), c.Position(4)*0.9];
    c.TickDirection = 'in';
    c.LineWidth = 1.1;
    c.FontSize = 10;
    % Transforming common values to vectors
    
    caxis(options{1})
    ylabel(c,sprintf('%s RMS MP%s value (cm)',GNScell{i},MPcode),'fontsize',10,'fontname','arial')
    axis equal
    axis tight
    axis off
    hold on
    text(60,0,-100,'30','FontSize',10,'HorizontalAlignment','center','background','w','fontname','arial','FontWeight','bold')
    text(30,0,-100,'60','FontSize',10,'HorizontalAlignment','center','background','w','fontname','arial','FontWeight','bold')
    
    % Exporting figure
    if saveFig == true
       splittedInputName = strsplit(xtrFileName,'.');  
       figName = [splittedInputName{1}, '_', GNScell{i}, '_MP', MPcode];
       print(figName,'-dpng',sprintf('-r%s',options{3}))
    end
end