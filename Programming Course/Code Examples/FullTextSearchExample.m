%%
%   SPECCCHIO Full Text Search Example
%
%   This code connects to sc22.geo.uzh.ch and selects the Merzen flying
%   goniometer datasets and plots the spectra and the angular sampling
%   pattern.
%
%   For details on how to setup Matlab in connection with SPECCHIO see the
%   online programming guide: 
%   https://specchio.ch/programming-course/
%   
%
%   (c) 2022 ahueni, RSL, University of Zurich
%
%

% add specchio path to java class path
 
javaaddpath ('/Applications/SPECCHIO/SPECCHIO.app/Contents/Java/specchio-client.jar');
 
% a few imports to avoid full specification of java package pathes
import ch.specchio.client.*;    
import ch.specchio.queries.*;
import ch.specchio.gui.*;
import ch.specchio.types.*;

% connect to SPECCHIO
cf = SPECCHIOClientFactory.getInstance();
db_descriptor_list = cf.getAllServerDescriptors();

% change this index to match your local SPECCHIO installation and it's
% known data connections: this example requires a connection to
% sc22.geo.uzh.ch and the specchio_prod database as data source.
index = 6; % index into the list of known database connection, identical to the one seen in the SPECCHIO client app: this is specchio_prod on specchio server sc22.geo.uzh.ch (on Andy's machine)
db_descriptor_list.get(index)
specchio_client = cf.createClient(db_descriptor_list.get(index));

matching_ids = specchio_client.getSpectrumIdsMatchingFullTextSearch("UAV Based Goniometer");

matching_ids.size

% get campaign info as distinct values for all matching ids
campaign_info = specchio_client.getMetaparameterValues(matching_ids, 'Campaign Name', java.lang.Boolean.TRUE); 
disp(campaign_info.toString)


spaces = specchio_client.getSpaces(matching_ids, 1, 0, 'Acquisition Time');

space = spaces(1);
ids = space.getSpectrumIds(); % get properly ordered ids !!!!!!!
space = specchio_client.loadSpace(space);


vectors = space.getVectorsAsArray();
wvl = space.getAverageWavelengths();

out.spectra = vectors;
out.wvl = wvl;

azimuths_ = specchio_client.getMetaparameterValues(ids, 'Sensor Azimuth');
zeniths_ = specchio_client.getMetaparameterValues(ids, 'Sensor Zenith');
alt_ = specchio_client.getMetaparameterValues(ids, 'Sensor Distance');


azimuths = azimuths_.get_as_double_array();
zeniths = zeniths_.get_as_double_array();
alt = alt_.get_as_double_array();

% get cartesian coords
x = sin(deg2rad(azimuths)).*cos(deg2rad(zeniths));

y = cos(deg2rad(azimuths)).*cos(deg2rad(zeniths));

theta = deg2rad(azimuths);
rho = (x.^2 + y.^2).^(0.5);


% plot results
figure
plot(out.wvl, out.spectra', 'LineWidth',1.2);
title('Reflectances', 'FontSize', 20);
xlabel('wvl [nm]', 'FontSize', 15);
ylabel('Reflectance Factor', 'FontSize', 15);
xlim([330 830]);

figure
h=polar(theta, rho, 'o');
set(h, 'MarkerSize', 10, 'MarkerFaceColor', 'b')
title('Goniometric Sampling points (Polar Coords.)', 'FontSize', 20)

