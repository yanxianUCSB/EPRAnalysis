function [Y,A]=SubtractIntegrate(x,y,interpolation_points,varargin)
%=================Option Flags==========
%Add 'interp' to show the interpolation line
%Add 'suppress' to suppress the plot and solely return the integrated data
%and/or the area under the curve (!caution: this is just the mean of the
%function after the user-inputted peak!)

%=================INFO==================
%This function will accept x and y data (originally designed for EPR 
%2nd derivative data, keep this in mind when interpreting the A-output), 
%for which it will try to subtract a baseline (i.e. 
%the bias will become approximately 0), except on the user-specified interval.
%It will return the integrated data in Y and the mean value of Y after the
%right border of the interval. 

%The baseline will be 'guessed' with clamped spline interpolation (the
%spline will look like a line at the endpoints, or in other words: the 2nd
%derivative will be 0). The precision of this interpolation (how closely
%the interpolant should follow the original data) is controlled by
%interpolation_points: higher is more precise. The optimal value for
%interpolation_points can be guesstimated by adding the 'interp' specifier
%at the end of the argument list. This will display the interpolation line
%and allow the user to see how well this interpolation estimates the bias.

%The interval for which the function may not be spline-interpolated
%(because it is assumed to contain relevant data which is not noise/bias)
%will be specified by a figure-prompt that requires two mouseclicks to
%specify the (x-axis) interval.
%In that interval it will just linearly interpolate the start- and
%endpoints, as to avoid disturbing the data too much. 

%The next step is to subtract this interpolation from the y-values to
%remove the bias. The last step is integrating this data with the
%cumtrapz() function (to avoid amplifying noise too much, the user can of course
%experiment with different numerical integration methods and replace this
%on line 68).


%Initialize some useful variables. 
    xmin=min(x);
    xmax=max(x);  
    xsize=size(x);
    xrange=xmax-xmin;
    
    %Let user decide peak_min and peak_max
    figure(1)
    hold on
    plot(x,y,'b','Linewidth',1.5)
    title('Please select the start- and endpoint for the peak.')
    [xuser]=ginput(2);
    peak_min=xuser(1,1);
    peak_max=xuser(2,1);
    hold off
    close
    
    %Determine the x-stepsize with which the data should be interpolated
    xstep=round(xsize(1,1)/interpolation_points);
    peak_start=round((peak_min-xmin)*xsize(1,1)/xrange);
    peak_end=round((peak_max-xmin)*xsize(1,1)/xrange);
 
    
    %Interpolate the data cubically, but ignoring the interval containing
    %the peak (or any other relevant for of data).
    
    y_peakless=y;
    y_peakless(peak_start:peak_end,1)=0;
    y_peakless(peak_start:peak_end,1)=linspace(y(peak_start,1),y(peak_end,1),peak_end-peak_start+1);
    yy=spline(x(1:xstep:xsize(1,1)),[0; y_peakless(1:xstep:xsize(1,1)); 0],x);
    
    %Subtract the baseline
    y_sub=y-yy;
    
    %Integrate data
    Y=cumtrapz(x,y_sub);
    Ysize=size(Y);
    %Determine approximate area.
    A=mean(Y(peak_end:Ysize(1,1)));
    
    %============Plot data (or not...)=============
    
    %No extra specifiers: just a normal plot
    if size(varargin)==[0 0]
            hold on
            plot(x,y,'b',x,y_sub,'r',x,Y,'k','Linewidth',1.5)
            title('Results')
            %Indication of peak start & end (+'es) and x-axis
            plot([peak_min peak_min],[max(y) min(y)],'k-.','Linewidth',2)
            plot([peak_max peak_max],[min(y) max(y)],'k-.','Linewidth',2)
            plot([xmin xmax],[0 0],'k')
            legend('Original data','Subtracted data','Integrated data','Peak range')
            hold off   
    %Interpolation line if requested, or if the 'suppress' flag is used, no
    %plots at all. 
    else
        if strcmp(varargin(:,:),'suppress')~=1
            if strcmp(varargin(:,:),'interp')==1
                hold on
                plot(x,y,'b',x,y_sub,'r',x,yy,'k--','Linewidth',1)
                plot(x,Y,'k','Linewidth',2)
                title('Results')
                %Indication of peak start & end (+'es) and x-axis
                plot([peak_min peak_min],[max(y) min(y)],'k-.','Linewidth',2)
                plot([peak_max peak_max],[min(y) max(y)],'k-.','Linewidth',2)
                plot([xmin xmax],[0 0],'k')
                legend('Original data','Subtracted data','Interpolation','Integrated data','Peak range')
                hold off
            else
                hold on
                plot(x,y,'b',x,y_sub,'r',x,Y,'k','Linewidth',1.5)
                title('Results')
                %Indication of peak start & end (+'es) and x-axis
                plot([peak_min peak_min],[max(y) min(y)],'k-.','Linewidth',2)
                plot([peak_max peak_max],[min(y) max(y)],'k-.','Linewidth',2)
                plot([xmin xmax],[0 0],'k')
                legend('Original data','Subtracted data','Integrated data','Peak range')
                hold off
            end
        end
    end
    
%Written by Jan Morez on 28/02/2013 to prolong his lazyness. "No way I'm doing
%that manually."
end
