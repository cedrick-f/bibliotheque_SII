
% Mat�riaux
Materiau = containers.Map;
Materiau('B�ton') = struct('Conductivite', '0.92', ...  % Conductivit�s thermiques (W/(m.K))
                           'Capacite', '880', ...       % Capacit�s thermiques massiques (J/(kg.K))
                           'MasseVol', '2200', ...      % Masse volumique de la paroi (pas du mat�riau !) (kg/m^3)
                           'Image', 'beton.jpg');       % Fichier image
Materiau('B�ton arm�') = struct('Conductivite', '0.92', ...
                           'Capacite', '880', ...
                           'MasseVol', '2500', ...
                           'Image', 'betonarme.jpg');
Materiau('Brique pleine') = struct('Conductivite', '0.84', ...
                           'Capacite', '840', ...
                           'MasseVol', '1700', ...
                           'Image', 'brique.jpg');
Materiau('Brique terre cuite pleine') = struct('Conductivite', '0.840', ...
                           'Capacite', '1000', ...
                           'MasseVol', '2050', ...
                           'Image', 'terre_cuite.jpg');
Materiau('Parpaing Monomur') = struct('Conductivite', '0.125', ...
                           'Capacite', '1100', ...
                           'MasseVol', '575', ...
                           'Image', 'Monomur.jpg');
Materiau('Parpaing') = struct('Conductivite', '0.952', ...
                           'Capacite', '1080', ...
                           'MasseVol', '1185', ...
                           'Image', 'parpaing.jpg');
                       
Materiau('Roche volcanique') = struct('Conductivite', '0.996', ...
                           'Capacite', '1000', ...
                           'MasseVol', '1600', ...
                           'Image', 'roche_volcanique.jpg');
Materiau('B�ton cellulaire') = struct('Conductivite', '0.110', ...
                           'Capacite', '900', ...
                           'MasseVol', '425', ...
                           'Image', 'cellulaire.jpg');
Materiau('Platre') = struct('Conductivite', '0.8', ...
                           'Capacite', '830', ...
                           'MasseVol', '1600', ...
                           'Image', 'platre.jpg');

Materiau('Shiste ardoise') = struct('Conductivite', '1.864', ...
                           'Capacite', '1000', ...
                           'MasseVol', '2400', ...
                           'Image', 'ardoise.jpg');
                       
Materiau('Verre') = struct('Conductivite', '1.2', ...
                           'Capacite', '720', ...
                           'MasseVol', '2530', ...
                           'Image', 'verre.jpg');

Materiau('PMMA transparent') = struct('Conductivite', '0.19', ...
                           'Capacite', '1464', ...
                           'MasseVol', '1180', ...
                           'Image', 'verre.jpg');
                       
Materiau('PVC') = struct('Conductivite', '0.17', ...
                           'Capacite', '1046', ...
                           'MasseVol', '1200', ...
                           'Image', 'pvc.jpg');

Materiau('Sapin') = struct('Conductivite', '0.15', ...
                           'Capacite', '420', ...
                           'MasseVol', '450', ...
                           'Image', 'sapin.jpg');
Materiau('Panneau de particules agglom�r�es') = struct('Conductivite', '0.12', ...
                           'Capacite', '1584', ...
                           'MasseVol', '670', ...
                           'Image', 'agglomere.jpg');
Materiau('MDF') = struct('Conductivite', '0.18', ...
                           'Capacite', '1004', ...
                           'MasseVol', '926', ...
                           'Image', 'agglomere.jpg');
Materiau('Laine de verre') = struct('Conductivite', '0.044', ...
                           'Capacite', '1030', ...
                           'MasseVol', '18', ...
                           'Image', 'laine_verre.jpg');
Materiau('Laine de roche') = struct('Conductivite', '0.05', ...
                           'Capacite', '1030', ...
                           'MasseVol', '20', ...
                           'Image', 'laine_roche.jpg');
Materiau('PS extrud�') = struct('Conductivite', '0.03', ...
                           'Capacite', '1000', ...
                           'MasseVol', '10', ...
                           'Image', 'pvc.jpg');
Materiau('PS expans�') = struct('Conductivite', '0.039', ...
                           'Capacite', '1450', ...
                           'MasseVol', '15', ...
                           'Image', 'polystyrene.jpg');
Materiau('Ouate de cellulose souffl�') = struct('Conductivite', '0.042', ...
                           'Capacite', '1900', ...
                           'MasseVol', '15', ...
                           'Image', 'ouate.jpg');
Materiau('Mousse PU') = struct('Conductivite', '0.022', ...
                           'Capacite', '1500', ...
                           'MasseVol', '25', ...
                           'Image', 'polyurethane.jpg');


Materiau('Air') = struct('Conductivite', '0.024069', ...
                           'Capacite', '1006.103', ...
                           'MasseVol', '1.2921', ...
                           'Viscosite', '1.7e-5',  ...
                           'Image', 'air.jpg'); 
Materiau('Argon') = struct('Conductivite', '0.016349', ...
                           'Capacite', '521.929', ...
                           'MasseVol', '1.7818', ...
                           'Viscosite', '2.1e-5',  ...
                           'Image', 'argon.jpg'); 


% Vitrages
Vitrage = containers.Map;
Vitrage('Simple') = struct('Image', 'simple_vitrage.jpg');       % Fichier image
Vitrage('Double') = struct('Image', 'double_vitrage.jpg');       % Fichier image
Vitrage('Triple') = struct('Image', 'triple_vitrage.jpg');       % Fichier image


