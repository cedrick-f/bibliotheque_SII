classdef pnl_etat_module < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        panel
        parent
        bloc_PV
        dimensions
        pnls_etat_cell
        t_ncol
        t_temp
        sli
        nl
        ex
        ey
        dx
        dy
        Texte_I
        ax
        i
        h
        diode1
        diode2
        diode3
        diode4
        diode5
        b_diode
        fleche_x
        fleche_y
    end
    
    properties (SetObservable)
        TraceLC = []; % propriété "surveillée" pour le tracé des courbes "cellule"
    end
    
    methods
        function obj = pnl_etat_module(parent, position, bloc_PV)
            obj.parent = parent;
            obj.bloc_PV = bloc_PV;
            
            
            % Nombre de lignes et de colonnes du module
            nc = 4;
            obj.nl = str2double(get_param(bloc_PV, 's'));

            % Les dimensions des pannels de cellule
            px = position(1);
            py = position(2);
            obj.ex = 10;
            obj.ey = 10;
            obj.dx = 50;        % dimension du panel cellule en x
            obj.dy = obj.dx+17*2;
            
            % Les dimensions du panel
            obj.dimensions = [(obj.dx+obj.ex)*9+2*obj.ex+(obj.dx+obj.ex) (obj.dy+4*obj.ey)*4+obj.ey+80];
            
            % Le panel contenant le module
            pvpnl = uipanel('Parent',parent,'Title','Module photovoltaïque','FontSize',12,...
                    'FontWeight', 'bold',  ...
                    'Units', 'pixels', ...
                    'Position',[px py obj.dimensions(1) obj.dimensions(2)]);
            
            hh = obj.dy*4 + obj.ey*16 + obj.ey*2+10;
                
            % Le bouton pour ouvrir le mask du panneau
            bm = uicontrol('Parent', pvpnl, ...
                    'Style', 'pushbutton', 'String', 'Paramètres',...
                    'FontSize',10,...
                    'Position', [obj.dimensions(1)-obj.ex-90 hh  90 25],...
                    'TooltipString', 'Accéder aux paramètres détaillés du module PV', ...
                    'Callback', @(hObject, evt)bouton_mask_cb(obj));
            
            %
            % Le circuit
            %
            obj.ax =   axes('Parent',pvpnl,...
                        'Units','pixels',...
                        'XLim', [0 obj.dimensions(1)], ...
                        'XLimMode', 'manual', ...
                        'YLimMode', 'manual', ...
                        'YLim', [0 obj.dimensions(2)], ...
                        'Position',[0 0 obj.dimensions(1) obj.dimensions(2)],...
                        'Color',get(0,'defaultaxesColor'),...
                        'ColorOrder',get(0,'defaultaxesColorOrder'),...
                        'Tag','axes_circuit');
            axis off      
            
            % positions en Y des circuits horizontaux
            h = [obj.ey + obj.dy*3.5 + 4*obj.ey*4 ...
                 obj.ey + obj.dy*2.5 + 3*obj.ey*4 ...
                 obj.ey + obj.dy*1.5 + 2*obj.ey*4 ...
                 obj.ey + obj.dy*0.5 + 1*obj.ey*4];
            
            i = [2*obj.ey + obj.dy*3 + 3*obj.ey*4 ...
                 2*obj.ey + obj.dy*2 + 2*obj.ey*4 ...
                 2*obj.ey + obj.dy*1 + 1*obj.ey*4 ...
                 2*obj.ey];
            
            obj.i = i;
            obj.h = h;
            
            % positions en X des circuits verticaux
            x0 = 0;
            x1 = obj.ex;
            x2 = obj.dimensions(1)-obj.ex;
            
            % Epaisseur des lignes
            ep_c = 2.5;
            ep_f = 2.2;
            
            % Le circuit principal
            line([x0   x2   x2 x1 x1 x2 x2 x1 x1 x2 x2 x1 x1 x2 x2 x0],...
                 [h(1) h(1) i(1) i(1) h(2) h(2) i(2) i(2) h(3) h(3) i(3) i(3) h(4) h(4) i(4) i(4)], ...
                 'LineWidth', ep_c, ...
                 'Color', 'black' ...
                        )

            % Les fleches "courant"
            obj.fleche_x = [obj.ex/2 0 -obj.ex/2];
            obj.fleche_y = [-obj.ey  0  -obj.ey];
            
            for ii = 1:4
                 line(5*obj.ex-obj.fleche_y,...
                     obj.h(ii)+obj.fleche_x, ...
                     'LineWidth', ep_f, ...
                     'Color', 'red')
            end
            
            %
            % Les textes pour afficher les courants
            %
            obj.Texte_I = containers.Map;
            for c = 1:nc
                obj.Texte_I(num2str(c)) = uicontrol('Parent', pvpnl, ...
                        'Style', 'text', 'String', '0A',...
                        'TooltipString', 'Courant', ...
                        'FontSize',8,...
                        'HorizontalAlignment', 'right', ...
                        'Position', [2*obj.ex h(c)+6 45 15]);
                obj.Texte_I(['d' num2str(c)]) = uicontrol('Parent', pvpnl, ...
                        'Style', 'text', 'String', '0A',...
                        'TooltipString', 'Courant', ...
                        'FontSize',8,...
                        'HorizontalAlignment', 'left', ...
                        'Position', [3*obj.ex+6 h(c)-3*obj.ey 34 15]);
            end
            
            % Les diodes
            obj.trace_diode(1)
            
            uicontrol('Parent', pvpnl, ...
                        'Style', 'text', 'String', '+',...
                        'FontSize',14,...
                        'ForegroundColor', 'red', ...
                        'FontWeight', 'bold',  ...
                        'HorizontalAlignment', 'left', ...
                        'Position', [2 h(1)+4 18 18]);
            uicontrol('Parent', pvpnl, ...
                        'Style', 'text', 'String', '_',...
                        'FontSize',14,...
                        'ForegroundColor', 'red', ...
                        'FontWeight', 'bold',  ...
                        'HorizontalAlignment', 'left', ...
                        'Position', [2 i(4)+8 16 25]);
            
            %
            % Les panels des celules
            %
            obj.pnls_etat_cell = containers.Map;
            for c = 1:nc
                for l = 1:9
                    pnl = pnl_etat_cellule(pvpnl, ...
                         [obj.get_xy_cell(l,c) obj.dx l c], ...
                         bloc_PV);
                    addlistener(pnl,'TraceLC','PostSet',@obj.click_pv);
                    obj.pnls_etat_cell(num2str([c l])) = pnl;
                end
            end
            
            
            
            % 
            % La zone de saisie de la température de jonction
            %
            uicontrol('Parent', pvpnl, ...
                        'Style', 'text', 'String', 'Température (°C) ',...
                        'TooltipString', 'Saisir la température de jonction des cellules', ...
                        'FontSize',10,...
                        'HorizontalAlignment', 'right', ...
                        'Position', [2*obj.ex+150+26+14 hh 120 18]);
            obj.t_temp =  uicontrol('Parent', pvpnl, ...
                                'Style', 'edit', 'Value', 1000,...
                                'Position', [2*obj.ex+150+26+14+120 hh 30 19],...
                                'FontSize',10,...
                                'BackgroundColor', 'white', ...
                                'Min', -100, 'Max', 200, ...
                                'String', get_param(obj.bloc_PV, 'Tcell'), ...
                                'TooltipString', 'Saisir la température de jonction des cellules', ...
                                'Callback', @(src, evt)t_temp_cb(obj));
            
            %
            % Le texte pour définir le nombre de cellules
            %
            uicontrol('Parent', pvpnl, ...
                        'Style', 'text', 'String', 'Nombre de cellules : 4 x ',...
                        'TooltipString', 'Saisir le nombre de rangées de cellules', ...
                        'FontSize',10,...
                        'HorizontalAlignment', 'right', ...
                        'Position', [obj.ex hh 150 18]);
            obj.t_ncol =  uicontrol('Parent', pvpnl, ...
                                'Style', 'edit', 'Value', 9,...
                                'Position', [obj.ex+150 hh 25 19],...
                                'FontSize',10,...
                                'BackgroundColor', 'white', ...
                                'Min', 1, 'Max', 9, ...
                                'String', get_param(obj.bloc_PV, 's'), ...
                                'TooltipString', 'Saisir le nombre de rangées de cellules', ...
                                'Callback', @(src, evt)t_ncol_cb(obj));
            obj.sli = uicontrol('Parent',pvpnl,'Style','slider',...
                               'Max',9,'Min',1,'Value',9,...
                               'SliderStep',[1/8 1/8],...
                               'Position',[obj.ex+150+26 hh 14 19],...
                               'Callback',@(src, evt)s_ncol_cb(obj));
            obj.t_ncol_cb()                

            
            
            % Le bouton "diodes"
            obj.b_diode = uicontrol('Parent', pvpnl, ...
                        'Style', 'checkbox', 'String', 'Diodes Bypass',...
                        'TooltipString', 'Utiliser des diodes Bypass', ...
                        'FontSize',10,...
                        'Value', 1, ...
                        'HorizontalAlignment', 'right', ...
                        'Position', [2*obj.ex+150+26+14+120+60 hh 120 19], ...
                        'Callback',@(src, evt)b_diode_cb(obj));
            %
            % Sous fonctions
            %
                     
        end
        
        %
        % Callbacks
        %
        function click_pv(obj,src,event)
            c = event.AffectedObject.c;
            l = event.AffectedObject.l;
            obj.TraceLC = [l c];
        end
        
        
        function xy = get_xy_cell(obj, l, c)
            xy = [7*obj.ex+(9-obj.nl)*(obj.dx+obj.ex)/2+(l-1)*(obj.dx+obj.ex) ...
                  5*obj.ey+(4-c)*(obj.dy+4*obj.ey)];
        end
            
        
        function bouton_mask_cb(obj,src, evt)
            open_system(obj.bloc_PV, 'mask')
        end

        
        function t_ncol_cb(obj, src, evt)
            set(obj.sli, 'Value', str2num(get(obj.t_ncol, 'String')))
            nnl = get(obj.t_ncol, 'String');
            set_param(obj.bloc_PV, 's', nnl)
            obj.nl = str2double(nnl);
            obj.gerer_structure();
            obj.raz_ui_cell()
        end
        
        
        function b_diode_cb(obj, src, evt)
            obj.trace_diode(get(obj.b_diode, 'Value'))
            obj.raz_ui_cell()
        end
        
        
        function s_ncol_cb(obj, src, evt)
            set(obj.t_ncol, 'String', get(obj.sli, 'Value'))
            nnl = get(obj.t_ncol, 'String');
            set_param(obj.bloc_PV, 's', nnl)
            obj.nl = str2double(nnl);
            obj.gerer_structure();
            obj.raz_ui_cell()
        end
        
        
        function t_temp_cb(obj, src, evt)
            set_param(obj.bloc_PV, 'Tcell', get(obj.t_temp, 'String'))
            obj.raz_ui_cell()
        end
        
        
        function gerer_structure(obj)
            for c = 1:4
                for l = 1:9
                    o = obj.pnls_etat_cell(num2str([c l]));
                    if l <= obj.nl
                        x = o.set_visible('on');
                    else
                        x = o.set_visible('off');
                    end
                    pos = [obj.get_xy_cell(l,c) obj.dx obj.dy];
                    x = o.set_position(pos);
                end
            end
        end
        
        
        function maj_ui_cell(obj, U, I, Id)
            for c = 1:4
                for l = 1:9
                    pc = obj.pnls_etat_cell(num2str([c l]));
                    x = pc.maj_U(U(l,c));
                end
                obj.maj_I(num2str(c), I(1,c));
                obj.maj_I(['d' num2str(c)], Id(c));
            end
        end
        
        
        function raz_ui_cell(obj)
            for c = 1:4
                for l = 1:9
                    pc = obj.pnls_etat_cell(num2str([c l]));
                    x = pc.raz_U();
                    pc.set_image_cell();
                end
                set(obj.Texte_I(num2str(c)), 'String', '');
                set(obj.Texte_I(['d' num2str(c)]), 'String', '');
                
            end
        end
        
        
        function maj_img(obj)
            for c = 1:4
                for l = 1:9
                    pc = obj.pnls_etat_cell(num2str([c l]));
                    pc.set_image_cell();
                end
            end
        end
        
        
        function x= maj_I(obj, k, I)
            if abs(I) < 1e-6
                I = 0;
            end
            ch = regexprep(sprintf('%.2g', I), {'e-00','e-0'}, 'e-');
            ch = regexprep(ch, {'e+00','e+0'}, 'e+');
            ch = [ch 'A'];
            Icc = str2num(get_param(obj.bloc_PV, 'Icc'));
            cc = 0.3+(I/Icc)*0.7;
            if cc < 0
                color = [1 0 0];
            else
                color = [0 cc 0];
            end
            
            set(obj.Texte_I(k), 'String', ch, 'ForegroundColor', color);
            x=0;
        end
    
    
        % ------------------------------------------------------------
        % Trace le circuit avec les diodes
        % ------------------------------------------------------------
        function trace_diode(obj, visible)
            set(gcf,'CurrentAxes',obj.ax)
            
            % Epaisseur des lignes
            ep_c = 2.5;
            ep_f = 2.2;
            
            if visible == 1
                set_param(obj.bloc_PV, 'shunt_diode', '[1 1 1 1]')
                line_d1_x = 2*[0 0      obj.ex/2 0        -obj.ex/2 0     ];
                line_d1_y = 2*[0 obj.ey/2 obj.ey/2   1.5*obj.ey obj.ey/2    obj.ey/2]; 
                line_d2_x = 2*[obj.ex/2  -obj.ex/2];  
                line_d2_y = 2*[1.5*obj.ey  1.5*obj.ey];
                line_d3_x = 2*[0  0];  
                line_d3_y = 2*[1.5*obj.ey  3*obj.ey];
                for ii = 1:4
                    set(obj.Texte_I(['d' num2str(ii)]), 'Visible', 'on')
                     obj.diode1(ii) = line(3*obj.ex+line_d1_x,...
                         obj.i(ii)+line_d1_y, ...
                         'LineWidth', ep_c, ...
                         'Color', [0.3 0.3 1]);
                     obj.diode2(ii) = line(3*obj.ex+line_d2_x,...
                         obj.i(ii)+line_d2_y, ...
                         'LineWidth', ep_c, ...
                         'Color', [0.3 0.3 1]);
                     obj.diode3(ii) = line(3*obj.ex+line_d3_x,...
                          obj.i(ii)+line_d3_y, ...
                         'LineWidth', ep_c, ...
                         'Color', [0.3 0.3 1]);
                     
                     obj.diode4(ii) =   line(3*obj.ex+[0 0],...
                                            obj.h(ii)-[0 2*obj.ey], ...
                                             'LineWidth', ep_c, ...
                                             'Color', [0.3 0.3 1]);
                     obj.diode5(ii) =   line(3*obj.ex+obj.fleche_x,...
                                             obj.h(ii)-1.5*obj.ey+obj.fleche_y, ...
                                             'LineWidth', ep_f, ...
                                             'Color', 'red');
                end
            else
                set_param(obj.bloc_PV, 'shunt_diode', '[0 0 0 0]')
                for ii = 1:4
                    delete(obj.diode1(ii))
                    delete(obj.diode2(ii))
                    delete(obj.diode3(ii))
                    delete(obj.diode4(ii))
                    delete(obj.diode5(ii))
                    set(obj.Texte_I(['d' num2str(ii)]), 'Visible', 'off')
                end
            end
        end
        
        
    end
end

