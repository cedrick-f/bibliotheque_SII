classdef pnl_etat_cellule < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Slider
        Texte_U
        modele
        parent
        l
        c
        Img
        Axes
    end
    
    properties (SetObservable)
        TraceLC = []; % propriété "surveillée" pour le tracé des courbes "cellule"
    end
    
    methods
        function obj = pnl_etat_cellule(parent, position, model)
            % <position> contient : x, y, w 
            % et la position sur le module : l et c
            
            % Une chaine définissant le bloc en lien avec le panel
            obj.modele = model; 
            
            % La figure ou panel "parent"
            obj.parent = parent;
            
            % La position de la cellule sur le module
            obj.l = position(4);
            obj.c = position(5);
            
            %
            % L'image de la cellule
            %
            posImg = [position(1), position(2)+17, position(3), position(3)];
%             obj.Axes = axes(...
%                             'Parent',parent,...
%                             'Units','pixels',...
%                             'FontUnits','pixels',...
%                             'Position',posImg,...
%                             'Color',get(0,'defaultaxesColor'),...
%                             'ColorOrder',get(0,'defaultaxesColorOrder'),...
%                             'FontSize',13.3333333333333,...
%                             'XColor',get(0,'defaultaxesXColor'),...
%                             'YColor',get(0,'defaultaxesYColor'),...
%                             'ZColor',get(0,'defaultaxesZColor'),...
%                             'Tag','axes1_1');
%             set(gcf, 'CurrentAxes', obj.Axes)
%             [rgb, map, alpha] = imread('Electronique/cellule_photovoltaique2.jpg', 'jpg');
%             obj.Img = image(rgb, ...
%                             'Parent',obj.Axes);
%             %set(img, 'AlphaData', alpha)
%             axis off          
%             axis image
%             
%             set(parent, 'TooltipString', 'Cliquer pour afficher la courbe caractérisrique de la cellule seule')
%             set(obj.Img, 'ButtonDownFcn',@(src,event)click_pv(obj))
            
            
            obj.Axes = uicontrol('Parent',parent,'Style','ToggleButton',...
                               'Position',posImg,...
                               'TooltipString', 'Cliquer pour afficher la courbe caractérisrique de la cellule seule', ...
                               'Callback',@(src,event)click_pv(obj));
            
            obj.set_image_cell()
            
            
            %
            % Le slider pour régler l'occultation
            %
            posSlider = [position(1), position(2)+position(3)+17, position(3), 17];
            obj.Slider = uicontrol('Parent',parent,'Style','slider',...
                           'Max',100,'Min',0,'Value',100,...
                           'SliderStep',[0.05 0.2],...
                           'Position',posSlider,...
                           'TooltipString', ['Déplacer pour occulter la cellule ' num2str(obj.c) '.' num2str(obj.l)], ...
                           'SliderStep', [0.1 0.5], ...
                           'Callback',@(src,event)slider_callback(obj));
            
            %
            % Le texte affichant la tension aux bornes de la cellule
            %             
            posText_U = [position(1), position(2), position(3), 17];           
            obj.Texte_U = uicontrol('Parent',parent,'Style','text',...
                           'String','',...
                           'HorizontalAlignment', 'center', ...
                           'FontSize',8,...
                           'TooltipString', ['Tension aux bornes de la cellule ' num2str(obj.c) '.' num2str(obj.l)], ...
                           'Position',posText_U);
            

            obj.maj_Occ();
            obj.maj_U(0);
        end
        
        
        %
        % Callbacks
        %
        function click_pv(obj,src,event)
            obj.TraceLC = [obj.l obj.c];
        end
        
        
        function set_image_cell(obj)
            switch get_param(obj.modele, 'typcell')
                case 'monocristallin'
                    [rgb, map, alpha] = imread('Electronique/mono.jpg', 'jpg');
                case 'polycristallin'
                    [rgb, map, alpha] = imread('Electronique/poly.jpg', 'jpg');
                case 'amorphe'
                    [rgb, map, alpha] = imread('Electronique/amorphe.jpg', 'jpg');
            end
            set(obj.Axes, 'Cdata', rgb)
        end
        
        
        function slider_callback(obj)
          val = get(obj.Slider,'Value');
          %val = str2double(get(obj.Slider,'Value'))%/100
          C = str2num(get_param(obj.modele, 'C'));
          D = str2num(get_param(obj.modele, 'D'));
          code = obj.c+obj.l/10;
          trouve = 0;
          for i = 1:numel(C)
              if C(i) == code
                  if val == 100
                      C = [C(1:i-1) C(i+1:numel(C))];
                      D = [D(1:i-1) D(i+1:numel(D))]; 
                  else
                    D(i) = val;
                  end
                  trouve = 1;
                  break
              end
          end
          if ~trouve & val ~= 100
              C = [C code];
              D = [D val];
          end
          
          set_param(obj.modele, 'C', ['[' num2str(C) ']'])
          set_param(obj.modele, 'D', ['[' num2str(D) ']'])
          
          %sim(gcs)
        end
        
        function x = maj_U(obj, U)
            ch = regexprep(sprintf('%.2g', U), {'e-00','e-0'}, 'e-');
            ch = regexprep(ch, {'e+00','e+0'}, 'e-');
            ch = [ch 'V'];
           
            Vco = str2num(get_param(obj.modele, 'Vco'));
            cc = 0.3+(U/Vco)*0.7;
            if cc < 0
                color = [1 0 0];
            else
                color = [0 0 cc];
            end
        
            set(obj.Texte_U, 'String', ch, 'ForegroundColor', color);
            x=0;
        end
        
        function x = raz_U(obj)
            set(obj.Texte_U, 'String', '');
            x=0;
        end
        
        function maj_Occ(obj)
          C = str2num(get_param(obj.modele, 'C'));
          D = str2num(get_param(obj.modele, 'D'));
          code = obj.c+obj.l/10;
          for i = 1:numel(C)
              if C(i) == code
                  set(obj.Slider,'Value', D(i));
              end
          end 
        end
        
        function x=set_visible(obj, v)
            %set(obj.Img, 'Visible', v)
            set(obj.Axes, 'Visible', v)
            set(obj.Slider, 'Visible', v)
            set(obj.Texte_U, 'Visible', v)
            x=0;
        end
        
        function x=set_position(obj, p)
            set(obj.Axes, 'Position', [p(1), p(2)+17, p(3), p(3)])
            set(obj.Slider, 'Position', [p(1), p(2)+p(3)+17, p(3), 17])
            set(obj.Texte_U, 'Position', [p(1), p(2), p(3), 17])
            x=0;
        end
    end
    
end

