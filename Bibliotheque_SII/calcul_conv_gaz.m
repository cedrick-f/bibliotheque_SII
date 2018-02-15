function hsi = calcul_conv_gaz(gaz, e, itr, Materiau)
  

% Glazing system inclined at 0° (? = 0° )
  %A = 0.16 ; 
  %n = 0.28;
  % Glazing system inclined at 45° (? = 45° )
  %A = 0.10 ; 
  %n = 0.31;
  % Glazing system inclined at 90° (? = 90° ) = vertical
  A = 0.035;
  n = 0.38;
  si = str2double(e)/1000; % épaisseur (m)
  raui = str2double(Materiau(gaz).MasseVol);
  cpi = str2double(Materiau(gaz).Capacite); % chaleur spécifique (J/(g.K))
  lmbi = str2double(Materiau(gaz).Conductivite); % conductivité thermique (W/(m.K))
  DT = 15; % --> DetlaT entre les 2 parois (CEN)
  Tm = 283; %K --> température de référence du gaz (CEN)
  visc = str2double(Materiau(gaz).Viscosite); % --> viscosité du gaz (kg/(m.s))
  Gr = 9.81 * DT * raui^2 * si^3 / (Tm * visc^2);   % k1 déterminé "à la louche"
  
  Pr = visc * cpi / lmbi;
  Nui = max(A*(Gr*Pr)^n, 1);
  hgsi = Nui * lmbi/si;
  if strcmp(itr, 'on')
      emis = 0.04;
  else
      emis = 0.840;
  end
  hrsi = 4*5.6697e-8/(1/0.840 + 1/emis - 1) * Tm^3;
  hsi = num2str(hrsi + hgsi);
end