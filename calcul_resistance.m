

function calcul_resistance(bloc, Materiau)
% Calcul la résistance thermique du vitrage et l'affiche dans le mask

    hi = str2double(get_param([bloc '/Conv_int'], 'heat_tr_coeff'));
    he = str2double(get_param([bloc '/Conv_ext'], 'heat_tr_coeff'));

    uverre = str2double(Materiau('Verre').Conductivite);
    typ = get_param(bloc, 'typ');
    
    switch typ
        case 'Simple'
            uvi = uverre;
            evi = str2double(get_param(bloc, 'ev'));
            uv = 1;
            ev = 0;
            uve = 1;
            eve = 0;
            hgi = Inf;
            hge = Inf;
           
        case 'Double'
            uvi = uverre;
            evi = str2double(get_param(bloc, 'evi'));
            uv = 1;
            ev = 0;
            uve = uverre;
            eve = str2double(get_param(bloc, 'eve'));
            hgi = str2double(calcul_conv_gaz(get_param(bloc, 'gaz'), ...
                                  get_param(bloc, 'eg'), ...
                                  get_param(bloc, 'itr'), Materiau));
            hge = Inf;

        case 'Triple'
            uvi = uverre;
            evi = str2double(get_param(bloc, 'evi'));
            uv = uverre;
            ev = str2double(get_param(bloc, 'ev0'));
            uve = uverre;
            eve = str2double(get_param(bloc, 'eve'));
            hgi = str2double(calcul_conv_gaz(get_param(bloc, 'gaz'), ...
                                  get_param(bloc, 'egi'), ...
                                  get_param(bloc, 'itr'), Materiau));
            hge = str2double(calcul_conv_gaz(get_param(bloc, 'gaz'), ...
                                  get_param(bloc, 'ege'), ...
                                  get_param(bloc, 'itr'), Materiau));
            
    end
    
    R = 1/hi + 1/hgi + (evi/uvi + ev/uv + eve/uve)/1000 + 1/hge + 1/he;
    U = 1/R;
 	set_param(gcb, 'R', num2str(R))
    set_param(gcb, 'U', num2str(U))
  
end


