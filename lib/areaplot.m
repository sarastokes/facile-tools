function hh = areaplot(x,y,threshold)
% AREAPLOT  Filled area plot.
% For vector x and y. The area above the threshold is displayed green
% and below in red. By default the threshold is 0. In order to color the
% area to the threshold line, interceptpoints are calculated using interpolation. 
%
% Ben van Oeveren, 5-08-2015
if ~exist('threshold','var')
        threshold=0;
end
if nargin==1
    y = x;
    x = 1:length(y);
elseif length(y)==1 && length(x)>1
    threshold=y;
    y = x;
    x = 1:length(y);
end
plot(x,y,'-b')
plot(x,y,'*r')
%interpolate
[up,down]  =interpolate(x,y,threshold);
[x,i] = sort([x(:);up;down]);
y2 = [y;ones(length([up;down]),1).*threshold];
y = y2(i);
Yu = ones(length(y),1).*threshold;
Yd = ones(length(y),1).*threshold;
Yu(y>=threshold) = y(y>=threshold);
Yd(y<=threshold) = y(y<=threshold);
hold on
hcolor = 'g';
h=area(x,[repmat(threshold,size(Yu)), Yu-threshold]);
set(h(1),'FaceColor','none','LineStyle','none');
set(h(2),'FaceColor',hcolor,'LineStyle','none');
delete(h(1))
hold on
lcolor = 'r';
g=area(x,[repmat(threshold,size(Yd)),Yd-threshold]);
set(g(1),'FaceColor','none','LineStyle','none');
set(g(2),'FaceColor',lcolor,'LineStyle','none');
delete(g(1))
if nargout>0, hh = [h(2),g(2)]; end
end
function [up,down]  =interpolate(x,y,threshold)
down = [];
ind = y>threshold;
t = diff(ind);
up = [find(t==1);find(t==-1)];
y_0= y([up up+1]);
x_0 = x([up up+1]);
opp = diff(y_0,[],2);
adj = diff(x_0,[],2);
alp = atan(opp./adj);
xx = (threshold-y_0(:,1))./tan(alp)+x_0(:,1);
nr = sum(t==1);
if nr == 0 
   rng = [min(y), max(y)];
   flag = all(sign(threshold-rng)==1); %0 = threshold<y
   if flag %1 = threshold>y
       down = [0;length(y)];
   else %0 = threshold<y 
       up = [0;length(y)];
   end
else 
    up = xx(1:nr);
    down = xx(nr:end); 
end
end