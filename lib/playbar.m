classdef PlayBar < handle
%PLAYBAR a figure toolbar add-on for visualizing sequential data
%
%   The toolbar provides VCR like buttons for playing, or steping forward
%   or backwards through sequential data.  Functions like a video player.
%
%   playBar = PlayBar( hFig, maxIndex ) creates a uitoolbar in the figure,
%   hFig, with a maximum index of maxIndex.
%
%   playBar = PlayBar( hFig ) creates a uitoolbar in the figure,
%   hFig, with a maximum index set tp the default of 100.
%
%   playBar = PlayBar() creates an un-initialized PlayBar object.  The
%   object is initialized using the initialize method
%       playBar.initialize(hFig,maxIndex)
%
% Example : Create a PlayBar to visualize the peaks function.  This example
% is modified from an example in the getframe help documentation
%
% function samplePlayBar
% % Create a figure
%   hFig = figure();
%   Z = peaks;
%   hSurf = surf(Z);
%   axis tight manual
%   ax = gca;
%   ax.NextPlot = 'replaceChildren';
% % Create the PlayBar object with a maximum index of 100
%   playBar = PlayBar(hFig,100);
% % Create a listener to listen for the PlayBar's UpdateEvent event
%   addlistener(playBar,'UpdateEvent',@onUpdate);
% 
%     function onUpdate( hSource, hEventData )
%         j = 4 + hSource.getIndex;
%         newZ = sin(j*pi*0.1)*Z;
%         hSurf.ZData = newZ;
%         drawnow();       
%     end
% end 
%
% Notes:
% - Uses undocumented matlab features, see https://undocumentedmatlab.com/
% - Should behave correctly when the figure is docked with matlab version
%   2016a and greater
%
% Collin Pecora 2/19
    properties(Access = private)
        % Array of java buttons
        jActionButtons
        % Array of java textfields
        jIndexFields
        % timer
        hPlayTimer                          = timer.empty;    
        % Maximum index
        MaxIndex@int32 scalar               = 100;
        % Listeners
        StateListeners
        % Current State
        STATE@uint8 scalar                   = 1;        
    end
    properties(Access = private, Constant = true)
        % Action constants
        ACTION_BACK2BEG@uint8 scalar        = 1;
        ACTION_BACK10@uint8 scalar          = 2;
        ACTION_BACK1@uint8 scalar           = 3;
        ACTION_PLAY@uint8 scalar            = 4;
        ACTION_FORWARD1@uint8 scalar        = 5;
        ACTION_FORWARD10@uint8 scalar       = 6;
        ACTION_FORWARD2END@uint8 scalar     = 7;
        % State constants
        STATE_BOF@uint8 scalar              = 1;
        STATE_EOF@uint8 scalar              = 2;
        STATE_INRANGE@uint8 scalar          = 3; 
        % Mode constants
        MODE_PLAYING@uint8 scalar           = 1;
        MODE_IDLE@uint8 scalar              = 2;
        MODE_NOTENEABLED@uint8 scalar       = 3;
        % Default frame rate
        DEFAULT_FPS                         = 25;
        % Default toolbar height
        DEFAULT_HEIGHT                      = 20;
    end   
    properties(Access = private,SetObservable, AbortSet)
        % Current mode
        MODE@uint8 scalar                   = 2; 
        % Current Index
        CurrentIndex@int32 scalar           = 1;
    end    
    
    events
       UpdateEvent 
    end
    
    methods
        function this = PlayBar( hFig, maxIndex )
            
            narginchk(0,2)
            
            if nargin
                if isequal(nargin,1)
                    maxIndex = this.MaxIndex;
                end
                this.initialize(hFig,maxIndex)
            end
         end
        
        function delete( this )
            delete(this.StateListeners);
            try
                if isvalid(this.hPlayTimer)
                    if strcmp(this.hPlayTimer.Running,'on')
                        this.hPlayTimer.Running,'off';
                    end
                    delete(this.hPlayTimer);
                end
            catch
            end            
        end
        
        function index = getIndex( this )
            % Return the current index as a double
            index = double(this.CurrentIndex); 
        end
        
        function rate = getActualPlaybackRate( this )
            % Get the actual playback rate if timer is running
            rate = [];
            
            if strcmp(this.hPlayTimer.Running,'on')
                rate = 1/this.hPlayTimer.AveragePeriod;
            end            
        end
        
        function initialize( this, hFig, maxIndex )
            % Initialize graphics
            narginchk(3,3)
            % Validate figure handle
            if isvalid(hFig)
                if isa(hFig,'matlab.ui.Figure')
                    hFig.CloseRequestFcn = @this.onFigClose;
                else
                    error('PlayBar:NotAFigure',...
                        ['Expected hFig to be a matlab.ui.Figure, instead it was a ',...
                        class(hFig)]);
                end
            else
                error('PlayBar:InvalidFigureHandle',...
                    'Invalid or deleted figure handle');
            end
            if ischar(maxIndex) || isstring(maxIndex)
                
                maxIndex = str2double(maxIndex);
            end
            
            validateattributes(maxIndex,{'numeric'},...
                {'nonempty','nonnan','scalar','>',0})
            this.MaxIndex = int32(maxIndex);
            this.StateListeners = ...
                [addlistener(this,'MODE','PostSet',@this.onModeChange),...
                 addlistener(this,'CurrentIndex','PostSet',@this.onIndexChange)];
                               
            this.createToolBar(hFig);
            
            this.hPlayTimer = timer(...
                'Name','PlayBarTimer',...
                'Period',1/this.DEFAULT_FPS,...
                'ExecutionMode','fixedDelay',...
                'BusyMode','queue',...
                'TimerFcn',@this.timerPlayFcn,...
                'ErrorFcn',@this.onTimerError);            
            
            this.MODE = this.MODE_IDLE;
            
            this.onModeChange([],[]);            
            
        end
    end
    
    methods (Access = private)
        function createToolBar( this, hFig )
            hToolBar = uitoolbar('Parent',hFig);
           
            hFig.Visible = 'on';
            drawnow()
            drawnow()
            
            icons = getIconImages();          
            
            jToolBar = get(get(hToolBar,'JavaContainer'),'ComponentPeer');       
            jToolBar.add(createHorizontalGlue);             
            jFrameNumberPanel = this.createFrameNumberPanel(icons.jump_to);
            jToolBar.add(jFrameNumberPanel);
            jToolBar.markAsNonEssential(jFrameNumberPanel);
            
            jToolBar.addSeparator();
            this.addActionButtons(jToolBar,icons);
            
            jToolBar.addSeparator();
            jFrameRatePanel = this.createFrameRatePanel();
            jToolBar.add(jFrameRatePanel);
            jToolBar.markAsNonEssential(jFrameRatePanel);
            jToolBar.add(createHorizontalGlue);
            jToolBar.revalidate;
            jToolBar.repaint;
        end
        
         function addActionButtons( this, toolbar, icons )
            
            this.jActionButtons = [...
                this.createButton(icons.goto_start_default,this.ACTION_BACK2BEG,'Go to beginning');...
                this.createButton(flip(icons.ffwd_default,2),this.ACTION_BACK10,'Back 10');...
                this.createButton(icons.step_back,this.ACTION_BACK1,'Back 1');...
                this.createToggleButton(icons.stop_default,icons.play_on,this.ACTION_PLAY,'Play');...
                this.createButton(icons.step_fwd,this.ACTION_FORWARD1,'Forward 1');...
                this.createButton(icons.ffwd_default,this.ACTION_FORWARD10,'Forward 10');...
                this.createButton(icons.goto_end_default,this.ACTION_FORWARD2END,'Goto end')];
            for itr = 1:numel(this.jActionButtons)
               toolbar.add(this.jActionButtons(itr)); 
            end
  
        end        
        
        function button = createButton( this, image, index, tooltip )
            cls = 'com.mathworks.mwswing.MJButton';
            icon = javax.swing.ImageIcon(im2java(image));         
            button = javaObjectEDT(cls,icon);
            button.setToolTipText(tooltip);
            button.setEnabled(false);
            button.setOpaque(false);
            cls = 'com.mathworks.mwswing.MJToolBar';
            javaMethodEDT('configureButton',cls,button); 
            button = handle(button,'CallbackProperties');
            button.ActionPerformedCallback = {@this.onVideoAction,index};            
        end
        
        function button = createToggleButton( this, onimage, offimage, index, tooltip )
            cls = 'com.mathworks.mwswing.MJToggleButton';
            icon = javax.swing.ImageIcon(im2java(offimage));         
            button = javaObjectEDT(cls,icon);
            button.setSelectedIcon(javax.swing.ImageIcon(im2java(onimage)));
            button.setToolTipText(tooltip);
            button.setEnabled(false);
            button.setOpaque(false);
            cls = 'com.mathworks.mwswing.MJToolBar';
            javaMethodEDT('configureButton',cls,button);
            button = handle(button,'CallbackProperties');
            button.ItemStateChangedCallback = {@this.onVideoAction,index};            
        end  
        function panel = createFrameNumberPanel( this, icon )
            
            icon = javax.swing.ImageIcon(im2java(icon));
            
            cls = 'com.mathworks.mwswing.MJToggleButton';
            jBut = handle(javaObjectEDT(cls,icon),'CallbackProperties');
            jBut.setToolTipText('Enable jump to');
            cls = 'com.mathworks.mwswing.MJToolBar';
            javaMethodEDT('configureButton',cls,jBut); 
            jBut.ItemStateChangedCallback = @this.onJumpToEnable;
            
            jCurrentIndex = creatTextField('1','Current frame');
            jCurrentIndex.ActionPerformedCallback = @this.onJumpTo;
 
            jMaxIndex = creatTextField(sprintf('%d',this.MaxIndex),...
                'Last frame number');
            jMaxIndex.ActionPerformedCallback = @this.onSetMaxIndex;
            
            this.jIndexFields = [jCurrentIndex;jMaxIndex];
            
            cls = 'com.mathworks.mwswing.MJLabel';
            jOfLabel = javaObjectEDT(cls,'of');
            jOfLabel.setHorizontalAlignment(javax.swing.JLabel.CENTER); 
 
            jFrameLabel = javaObjectEDT(cls,'Frame');
            jOfLabel.setHorizontalAlignment(javax.swing.JLabel.RIGHT);              
            
            panel = createJavaPanel();
            
            panel.add(jBut);
            panel.add(createHorizontalStrut(4));
            panel.add(jFrameLabel);
            panel.add(createHorizontalStrut(8));
            panel.add(jCurrentIndex);
            panel.add(createHorizontalStrut(4));
            panel.add(jOfLabel);         
            panel.add(createHorizontalStrut(4));
            panel.add(jMaxIndex);
            
        end
        
        function panel = createFrameRatePanel( this )
            fpscell = {'5 fps','10 fps','15 fps','20 fps','25 fps','30 fps'};
            jPlayBackCombo = createComboBox(fpscell,'Playback rate');
            jPlayBackCombo.ActionPerformedCallback =  @this.onSetPeriod;
            cls = 'com.mathworks.mwswing.MJLabel';
            jFrameRateLabel = javaObjectEDT(cls,'Frame Rate');
            jFrameRateLabel.setHorizontalAlignment(javax.swing.JLabel.RIGHT);   
            
            panel = createJavaPanel();
            
            panel.add(jFrameRateLabel);
            panel.add(createHorizontalStrut(8));
            panel.add(jPlayBackCombo);            
                
        end
        
        function onJumpTo( this, src, evnt )
            newIndex = str2double(char(evnt.getActionCommand));
            if isnan(newIndex)
                src.setText(sprintf('%d',this.CurrentIndex));
                return;
            end
            if (newIndex >= this.MaxIndex)
                src.setText(sprintf('%d',this.MaxIndex));
                this.CurrentIndex = this.MaxIndex;
                newState = this.STATE_EOF;
            elseif (newIndex < 1 )   
                src.setText(sprintf('%d',1));
                this.CurrentIndex = int32(1);
                newState = this.State_BOF; 
            else
                this.CurrentIndex = uint32(newIndex);
                newState = this.STATE_INRANGE;
                
            end
            src.revalidate;
            this.STATE = newState;
            this.onModeChange([],[]);
        end
        
        function onSetMaxIndex( this, src, evnt )
            newMax = str2double(char(evnt.getActionCommand));
            if isnan(newMax)
                src.setText(sprintf('%d',this.MaxIndex));
                return;
            end  
            
            this.MaxIndex = int32(newMax);
        end
        
        function onJumpToEnable( this, src, ~ )
            if isequal(this.MODE,this.MODE_PLAYING)
                this.MODE = this.MODE_IDLE;
            end
            this.jIndexFields(1).setEnabled(src.isSelected)
            this.jIndexFields(2).setEnabled(src.isSelected)
        end
        
        function onIndexChange( this, ~, ~ )
            this.jIndexFields(1).setText(sprintf('%d',this.CurrentIndex));
            notify(this,'UpdateEvent')
        end
        
        function onFigClose( this, src, ~ )
            try
                if isvalid(this.hPlayTimer)
                    if strcmp(this.hPlayTimer.Running,'on')
                        this.hPlayTimer.Running,'off';
                    end
                    delete(this.hPlayTimer);
                end
            catch
            end
            delete(this)
            delete(src);
        end        
        
        function onModeChange( this, ~, ~ )
           
            switch this.MODE                
                case {this.MODE_PLAYING,this.MODE_IDLE}
                    switch this.STATE
                        case this.STATE_BOF 
                            
                            for itr = this.ACTION_BACK2BEG:this.ACTION_BACK1
                                this.jActionButtons(itr).setEnabled(false);
                            end 
                            
                            for itr = this.ACTION_PLAY:this.ACTION_FORWARD2END
                                this.jActionButtons(itr).setEnabled(true);
                            end
                            
                            this.jActionButtons(this.ACTION_PLAY).setSelected(false);
                        case this.STATE_EOF  
                            
                            for itr = this.ACTION_PLAY:this.ACTION_FORWARD2END
                                this.jActionButtons(itr).setEnabled(false);
                            end
                            
                            for itr = this.ACTION_BACK2BEG:this.ACTION_BACK1
                                this.jActionButtons(itr).setEnabled(true);
                            end 
                            
                            this.jActionButtons(this.ACTION_PLAY).setSelected(false);
                        case this.STATE_INRANGE
                            
                            for itr = 1:numel(this.jActionButtons)
                                this.jActionButtons(itr).setEnabled(true);
                            end
                    end
                case this.MODE_NOTENABLED
            end
            drawnow()
        end
        function move( this, count )
            count = int32(count);
            
            newIndex = this.CurrentIndex + count;
            
            if (newIndex < this.MaxIndex) && (newIndex > 1 )
                this.CurrentIndex = this.CurrentIndex + count;
                this.STATE = this.STATE_INRANGE;
                this.onModeChange([],[]); 
            elseif (newIndex >= this.MaxIndex)
                stop(this.hPlayTimer);
                this.STATE = this.STATE_EOF;
                this.CurrentIndex = this.MaxIndex;
                this.MODE = this.MODE_IDLE;
                this.onModeChange([],[]);
            else 
                stop(this.hPlayTimer);
                this.STATE = this.State_BOF; 
                this.CurrentIndex = int32(1);
                this.onModeChange([],[]);                              
            end
        end
        function onSetPeriod( this, src, ~ )
            sel = src.getSelectedIndex + 1;
            fps = 5:5:30;
            newperiod = round((1/fps(sel))*1000)/1000;
            if strcmp(this.hPlayTimer.Running,'off')
                this.hPlayTimer.Period = newperiod;
            else
                stop(this.hPlayTimer);
                this.hPlayTimer.Period = newperiod;
                pause(0.001)
                start(this.hPlayTimer);
            end
        end
        
        function timerPlayFcn( this, ~, ~ )
            this.move(1);
        end 
        function onVideoAction( this, src, ~, action )
            switch action
                case this.ACTION_PLAY  
                    
                    if src.isSelected
                        start(this.hPlayTimer);
                        this.MODE = this.MODE_PLAYING;
                    else
                        stop(this.hPlayTimer);
                        this.MODE = this.MODE_IDLE;                       
                    end
                case this.ACTION_FORWARD1
                    
                    this.move(1);
                case this.ACTION_FORWARD10
                    
                    this.move(10)                   
                case this.ACTION_FORWARD2END
                    
                    this.CurrentIndex = this.MaxIndex;
                    this.STATE = this.STATE_EOF;
                    this.MODE = this.MODE_IDLE;
                    this.onModeChange([],[]);
                case this.ACTION_BACK1
                    
                    this.move(-1)
                case this.ACTION_BACK10
                    
                    this.move(-10)
                case this.ACTION_BACK2BEG
                    
                    this.CurrentIndex = int32(1);
                    this.STATE = this.STATE_BOF;
                    this.MODE = this.MODE_IDLE;
                    this.onModeChange([],[]);
            end
        end
    end
    
    
end
    
function text = creatTextField( str, tooltip )
    cls = 'com.mathworks.mwswing.MJTextField';
    text = handle(javaObjectEDT(cls),'CallbackProperties');
    text.setText(str);
    text.setToolTipText(tooltip);
    text.setHorizontalAlignment(javax.swing.JLabel.CENTER);
    jdim = java.awt.Dimension(40,20);
    text.setMinimumSize(jdim)
    text.setMaximumSize(jdim)
    text.setPreferredSize(jdim)  
    text.setBorder(javax.swing.BorderFactory.createEmptyBorder)
    text.setEnabled(false)
    text.setOpaque(false);
end
function combobox = createComboBox( items, tooltip )
    cls = 'com.jidesoft.combobox.ListComboBox';
%     cls = 'com.mathworks.mwswing.MJComboBox';
    combobox = handle(javaObjectEDT(cls,items),'CallbackProperties');
    combobox.setEditable(false);
    combobox.setFocusable(false);
    combobox.setToolTipText(tooltip);
    combobox.setSelectedIndex(uint8(3));
    jdim = java.awt.Dimension(60,20);
    combobox.setMinimumSize(jdim)
    combobox.setMaximumSize(jdim)
    combobox.setPreferredSize(jdim);
    combobox.setOpaque(false);
    combobox.setBorder(javax.swing.BorderFactory.createEmptyBorder);
    combobox.getEditor.getEditorComponent.setOpaque(false);
end
    
function panel = createJavaPanel()
    cls = 'com.mathworks.mwswing.MJPanel';
    panel = javaObjectEDT(cls);
    cls = 'javax.swing.BoxLayout';
    layout = javaObjectEDT(cls,panel,javax.swing.BoxLayout.X_AXIS);
    panel.setLayout(layout);
    panel.setOpaque(false);
end
function struct = createHorizontalStrut( width )
    cls = 'javax.swing.Box';
    struct = javaMethodEDT('createHorizontalStrut',cls,width);
end
function glue = createHorizontalGlue()
    cls = 'javax.swing.Box';
    glue = javaMethodEDT('createHorizontalGlue',cls);
end
function icons = getIconImages()
icons.goto_start_default = cat(3,[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN 0.2 0.2 0.482352941176471 NaN NaN NaN NaN 0.2 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN 0.2 0 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.482352941176471 NaN 0.2 0 0 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.482352941176471 0.2 0 0 0 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.482352941176471 NaN 0 0 0 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN 0 0 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN 0 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN NaN 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.482352941176471 0.482352941176471 0.482352941176471 NaN NaN NaN NaN NaN 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN 0.2 0.2 0.474509803921569 NaN NaN NaN NaN 0.2 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN 0.2 0 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.474509803921569 NaN 0.2 0 0 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.474509803921569 0.2 0 0 0 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.474509803921569 NaN 0 0 0 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN 0 0 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN 0 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN NaN 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.474509803921569 0.474509803921569 0.474509803921569 NaN NaN NaN NaN NaN 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN 0.2 0.2 0.486274509803922 NaN NaN NaN NaN 0.2 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN 0.2 0 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.486274509803922 NaN 0.2 0 0 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.486274509803922 0.2 0 0 0 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.486274509803922 NaN 0 0 0 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN 0 0 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN 0 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN NaN 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.486274509803922 0.486274509803922 0.486274509803922 NaN NaN NaN NaN NaN 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN]);
icons.step_back = cat(3,[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN 0.2 0.482352941176471 NaN NaN 0.2 0.2 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0.482352941176471 NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN 0.2 0 0 0 0.482352941176471 NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN 0.2 0 0 0 0 0.482352941176471 NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN 0 0 0 0 0.482352941176471 NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0 0 0 0.482352941176471 NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN NaN 0 0 0.482352941176471 NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN NaN NaN 0 0.482352941176471 NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN 0.482352941176471 NaN NaN 0.482352941176471 0.482352941176471 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN 0.2 0.474509803921569 NaN NaN 0.2 0.2 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0.474509803921569 NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN 0.2 0 0 0 0.474509803921569 NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN 0.2 0 0 0 0 0.474509803921569 NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN 0 0 0 0 0.474509803921569 NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0 0 0 0.474509803921569 NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN NaN 0 0 0.474509803921569 NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN NaN NaN 0 0.474509803921569 NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN 0.474509803921569 NaN NaN 0.474509803921569 0.474509803921569 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN 0.2 0.486274509803922 NaN NaN 0.2 0.2 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0.486274509803922 NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN 0.2 0 0 0 0.486274509803922 NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN 0.2 0 0 0 0 0.486274509803922 NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN 0 0 0 0 0.486274509803922 NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0 0 0 0.486274509803922 NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN NaN 0 0 0.486274509803922 NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN NaN NaN 0 0.486274509803922 NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN 0.486274509803922 NaN NaN 0.486274509803922 0.486274509803922 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN]);
icons.stop_default = cat(3,[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.423529411764706 0.423529411764706 0.423529411764706 0.423529411764706 0.423529411764706 0.423529411764706 0.423529411764706 0.423529411764706 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.415686274509804 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.415686274509804 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.415686274509804 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.415686274509804 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.415686274509804 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.415686274509804 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.415686274509804 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.415686274509804 NaN NaN NaN;NaN NaN NaN NaN 0.415686274509804 0.415686274509804 0.415686274509804 0.415686274509804 0.415686274509804 0.415686274509804 0.415686274509804 0.415686274509804 0.415686274509804 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.176470588235294 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.176470588235294 0 0 0 0 0 0 0 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN 0.423529411764706 0.423529411764706 0.423529411764706 0.423529411764706 0.423529411764706 0.423529411764706 0.423529411764706 0.423529411764706 0.423529411764706 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN]);
icons.step_fwd = cat(3,[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0.2 0.482352941176471 NaN NaN 0.2 NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.482352941176471 NaN NaN 0.2 0 NaN NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.482352941176471 NaN NaN 0.2 0 0 NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.482352941176471 NaN NaN 0.2 0 0 0 NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.482352941176471 NaN NaN 0.2 0 0 0 0 NaN NaN NaN NaN;NaN NaN 0.2 0 0.482352941176471 NaN NaN 0.2 0 0 0 0.482352941176471 NaN NaN NaN NaN;NaN NaN 0.2 0 0.482352941176471 NaN NaN 0.2 0 0 0.482352941176471 NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.482352941176471 NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.482352941176471 NaN NaN 0.2 0.482352941176471 NaN NaN NaN NaN NaN NaN NaN;NaN NaN 0.482352941176471 0.482352941176471 0.482352941176471 NaN NaN 0.482352941176471 NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0.2 0.474509803921569 NaN NaN 0.2 NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.474509803921569 NaN NaN 0.2 0 NaN NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.474509803921569 NaN NaN 0.2 0 0 NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.474509803921569 NaN NaN 0.2 0 0 0 NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.474509803921569 NaN NaN 0.2 0 0 0 0 NaN NaN NaN NaN;NaN NaN 0.2 0 0.474509803921569 NaN NaN 0.2 0 0 0 0.474509803921569 NaN NaN NaN NaN;NaN NaN 0.2 0 0.474509803921569 NaN NaN 0.2 0 0 0.474509803921569 NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.474509803921569 NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.474509803921569 NaN NaN 0.2 0.474509803921569 NaN NaN NaN NaN NaN NaN NaN;NaN NaN 0.474509803921569 0.474509803921569 0.474509803921569 NaN NaN 0.474509803921569 NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0.2 0.486274509803922 NaN NaN 0.2 NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.486274509803922 NaN NaN 0.2 0 NaN NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.486274509803922 NaN NaN 0.2 0 0 NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.486274509803922 NaN NaN 0.2 0 0 0 NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.486274509803922 NaN NaN 0.2 0 0 0 0 NaN NaN NaN NaN;NaN NaN 0.2 0 0.486274509803922 NaN NaN 0.2 0 0 0 0.486274509803922 NaN NaN NaN NaN;NaN NaN 0.2 0 0.486274509803922 NaN NaN 0.2 0 0 0.486274509803922 NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.486274509803922 NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN NaN NaN NaN;NaN NaN 0.2 0 0.486274509803922 NaN NaN 0.2 0.486274509803922 NaN NaN NaN NaN NaN NaN NaN;NaN NaN 0.486274509803922 0.486274509803922 0.486274509803922 NaN NaN 0.486274509803922 NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN]);
icons.ffwd_default = cat(3,[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.2 NaN NaN NaN NaN NaN 0.2 NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.2 0 NaN NaN NaN NaN 0.2 0 NaN NaN NaN NaN NaN;NaN NaN NaN 0.2 0 0 NaN NaN NaN 0.2 0 0 NaN NaN NaN NaN;NaN NaN NaN 0.2 0 0 0 NaN NaN 0.2 0 0 0 NaN NaN NaN;NaN NaN NaN 0.2 0 0 0 0 NaN 0.2 0 0 0 0 NaN NaN;NaN NaN NaN 0.2 0 0 0 0.482352941176471 NaN 0.2 0 0 0 0.482352941176471 NaN NaN;NaN NaN NaN 0.2 0 0 0.482352941176471 NaN NaN 0.2 0 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN NaN;NaN NaN NaN 0.2 0.482352941176471 NaN NaN NaN NaN 0.2 0.482352941176471 NaN NaN NaN NaN NaN;NaN NaN NaN 0.482352941176471 NaN NaN NaN NaN NaN 0.482352941176471 NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.2 NaN NaN NaN NaN NaN 0.2 NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.2 0 NaN NaN NaN NaN 0.2 0 NaN NaN NaN NaN NaN;NaN NaN NaN 0.2 0 0 NaN NaN NaN 0.2 0 0 NaN NaN NaN NaN;NaN NaN NaN 0.2 0 0 0 NaN NaN 0.2 0 0 0 NaN NaN NaN;NaN NaN NaN 0.2 0 0 0 0 NaN 0.2 0 0 0 0 NaN NaN;NaN NaN NaN 0.2 0 0 0 0.474509803921569 NaN 0.2 0 0 0 0.474509803921569 NaN NaN;NaN NaN NaN 0.2 0 0 0.474509803921569 NaN NaN 0.2 0 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN NaN;NaN NaN NaN 0.2 0.474509803921569 NaN NaN NaN NaN 0.2 0.474509803921569 NaN NaN NaN NaN NaN;NaN NaN NaN 0.474509803921569 NaN NaN NaN NaN NaN 0.474509803921569 NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.2 NaN NaN NaN NaN NaN 0.2 NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.2 0 NaN NaN NaN NaN 0.2 0 NaN NaN NaN NaN NaN;NaN NaN NaN 0.2 0 0 NaN NaN NaN 0.2 0 0 NaN NaN NaN NaN;NaN NaN NaN 0.2 0 0 0 NaN NaN 0.2 0 0 0 NaN NaN NaN;NaN NaN NaN 0.2 0 0 0 0 NaN 0.2 0 0 0 0 NaN NaN;NaN NaN NaN 0.2 0 0 0 0.486274509803922 NaN 0.2 0 0 0 0.486274509803922 NaN NaN;NaN NaN NaN 0.2 0 0 0.486274509803922 NaN NaN 0.2 0 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN NaN;NaN NaN NaN 0.2 0.486274509803922 NaN NaN NaN NaN 0.2 0.486274509803922 NaN NaN NaN NaN NaN;NaN NaN NaN 0.486274509803922 NaN NaN NaN NaN NaN 0.486274509803922 NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN]);
icons.goto_end_default = cat(3,[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN 0.2 NaN NaN NaN NaN NaN 0.2 0.2 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 NaN NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0 NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0 0 NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0 0.482352941176471 NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0.482352941176471 NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.2 0.482352941176471 NaN NaN NaN NaN 0.2 0 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN 0.482352941176471 NaN NaN NaN NaN NaN 0.482352941176471 0.482352941176471 0.482352941176471 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN 0.2 NaN NaN NaN NaN NaN 0.2 0.2 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 NaN NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0 NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0 0 NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0 0.474509803921569 NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0.474509803921569 NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.2 0.474509803921569 NaN NaN NaN NaN 0.2 0 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN 0.474509803921569 NaN NaN NaN NaN NaN 0.474509803921569 0.474509803921569 0.474509803921569 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN 0.2 NaN NaN NaN NaN NaN 0.2 0.2 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 NaN NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0 NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0 0 NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0 0.486274509803922 NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0 0.486274509803922 NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.2 0.486274509803922 NaN NaN NaN NaN 0.2 0 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN 0.486274509803922 NaN NaN NaN NaN NaN 0.486274509803922 0.486274509803922 0.486274509803922 NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN]);
icons.jump_to = cat(3,[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN 0.580392156862745 0.466666666666667 0.466666666666667 0.466666666666667 0.580392156862745 NaN NaN NaN NaN NaN;NaN NaN NaN NaN 0.580392156862745 0 0 0.2 0.2 0.2 0 0 0.580392156862745 NaN NaN NaN;NaN NaN NaN 0.580392156862745 0 0.466666666666667 NaN NaN NaN NaN NaN 0.466666666666667 0 0.580392156862745 NaN NaN;NaN NaN NaN 0 0.466666666666667 NaN NaN NaN NaN NaN NaN NaN 0.466666666666667 0 NaN NaN;NaN NaN 0.580392156862745 0 NaN NaN NaN NaN NaN NaN NaN NaN NaN 0 NaN NaN;NaN NaN 0.580392156862745 0 NaN NaN NaN NaN NaN NaN NaN 0 0 0 0 0;NaN NaN 0.580392156862745 0 NaN NaN NaN NaN NaN NaN NaN NaN 0 0 0 NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 0 NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN 0 0 0 0 0 NaN NaN NaN NaN NaN 0 0 0 0 0;NaN 0 0 0 0 0 NaN NaN NaN NaN NaN 0 0 0 0 0;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN 0.572549019607843 0.458823529411765 0.458823529411765 0.458823529411765 0.572549019607843 NaN NaN NaN NaN NaN;NaN NaN NaN NaN 0.572549019607843 0 0 0.2 0.2 0.2 0 0 0.572549019607843 NaN NaN NaN;NaN NaN NaN 0.572549019607843 0 0.458823529411765 NaN NaN NaN NaN NaN 0.458823529411765 0 0.572549019607843 NaN NaN;NaN NaN NaN 0 0.458823529411765 NaN NaN NaN NaN NaN NaN NaN 0.458823529411765 0 NaN NaN;NaN NaN 0.572549019607843 0 NaN NaN NaN NaN NaN NaN NaN NaN NaN 0 NaN NaN;NaN NaN 0.572549019607843 0 NaN NaN NaN NaN NaN NaN NaN 0 0 0 0 0;NaN NaN 0.572549019607843 0 NaN NaN NaN NaN NaN NaN NaN NaN 0 0 0 NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 0 NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN 0 0 0 0 0 NaN NaN NaN NaN NaN 0 0 0 0 0;NaN 0 0 0 0 0 NaN NaN NaN NaN NaN 0 0 0 0 0;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN 0.580392156862745 0.466666666666667 0.466666666666667 0.466666666666667 0.580392156862745 NaN NaN NaN NaN NaN;NaN NaN NaN NaN 0.580392156862745 0 0 0.2 0.2 0.2 0 0 0.580392156862745 NaN NaN NaN;NaN NaN NaN 0.580392156862745 0 0.466666666666667 NaN NaN NaN NaN NaN 0.466666666666667 0 0.580392156862745 NaN NaN;NaN NaN NaN 0 0.466666666666667 NaN NaN NaN NaN NaN NaN NaN 0.466666666666667 0 NaN NaN;NaN NaN 0.580392156862745 0 NaN NaN NaN NaN NaN NaN NaN NaN NaN 0 NaN NaN;NaN NaN 0.580392156862745 0 NaN NaN NaN NaN NaN NaN NaN 0 0 0 0 0;NaN NaN 0.580392156862745 0 NaN NaN NaN NaN NaN NaN NaN NaN 0 0 0 NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 0 NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN 0 0 0 0 0 NaN NaN NaN NaN NaN 0 0 0 0 0;NaN 0 0 0 0 0 NaN NaN NaN NaN NaN 0 0 0 0 0;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN]);
icons.play_on = cat(3,[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.482352941176471 0 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.482352941176471 0.211764705882353 0 0 NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.482352941176471 0.211764705882353 0.211764705882353 0.211764705882353 0 0 NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.482352941176471 0.211764705882353 0.211764705882353 0.211764705882353 0.211764705882353 0.211764705882353 0 0 NaN NaN NaN NaN NaN;NaN NaN NaN 0.482352941176471 0.211764705882353 0.211764705882353 0.211764705882353 0.211764705882353 0.211764705882353 0.211764705882353 0.211764705882353 0 0 NaN NaN NaN;NaN NaN NaN 0.482352941176471 0.211764705882353 0.211764705882353 0.211764705882353 0.211764705882353 0.211764705882353 0.211764705882353 0.211764705882353 NaN NaN NaN NaN NaN;NaN NaN NaN 0.482352941176471 0.211764705882353 0.211764705882353 0.211764705882353 0.211764705882353 0.211764705882353 NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.482352941176471 0.211764705882353 0.211764705882353 0.211764705882353 NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.482352941176471 0.211764705882353 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.482352941176471 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.474509803921569 0.4 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.474509803921569 1 0.4 0.4 NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.474509803921569 1 1 1 0.4 0.4 NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.474509803921569 1 1 1 1 1 0.4 0.4 NaN NaN NaN NaN NaN;NaN NaN NaN 0.474509803921569 1 1 1 1 1 1 1 0.4 0.4 NaN NaN NaN;NaN NaN NaN 0.474509803921569 1 1 1 1 1 1 1 NaN NaN NaN NaN NaN;NaN NaN NaN 0.474509803921569 1 1 1 1 1 NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.474509803921569 1 1 1 NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.474509803921569 1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.474509803921569 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN],[NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.486274509803922 0 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.486274509803922 0 0 0 NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.486274509803922 0 0 0 0 0 NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.486274509803922 0 0 0 0 0 0 0 NaN NaN NaN NaN NaN;NaN NaN NaN 0.486274509803922 0 0 0 0 0 0 0 0 0 NaN NaN NaN;NaN NaN NaN 0.486274509803922 0 0 0 0 0 0 0 NaN NaN NaN NaN NaN;NaN NaN NaN 0.486274509803922 0 0 0 0 0 NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.486274509803922 0 0 0 NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.486274509803922 0 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN 0.486274509803922 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN]);
end
