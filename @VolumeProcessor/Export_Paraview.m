% File: Export_Paraview.m @ VolumeProcessor
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 08.04.2019

% Description: Exports a volumetric dataset into a format readable by Paraview based
% on vtkwrite.m

% Input:
% 	- datasetPath - specifies path where we want to export to
%		- polarityHandler - specifies how we should handle the polarity
% 			none - keeps singals as bipolar signals
%				abs - uses the absolute of the signal
% 			pos - only keep positive signals
% 			neg - only keep negative signals
%		- normalize
%				1 - normalizes signals to range from 0 to 1
%				0 - do not normalize anything
% 	- nonFiniteHandler - specifies how we should handle non finite values
%				none - do not remove non finite elements
% 			remove - sets non finite elements to 0
% 			error - throw an error if this occurs

function Export_Paraview(vp, varargin)

	% default settings for function
	datasetPath = 'export.vtk';
	polarityHandler = 'abs';
	nonFiniteHandler = 'remove';
	flagNormalize = 1;

	% if no input path is specified save to default
	for iargin=1:2:(nargin-1)
		switch varargin{iargin}
			case 'datasetPath'
				datasetPath = varargin{iargin+1};
			case 'polarityHandler'
				polarityHandler = varargin{iargin+1};
			case 'nonFiniteHandler'
				nonFiniteHandler = varargin{iargin+1};
			case 'flagNormalize'
				flagNormalize = varargin{iargin+1};
			otherwise
				error('Unknown option');
		end
	end

	if (~isempty(vp.volume.vol))
		vp.VPrintf(['Exporting volume to ', datasetPath, '... '], 1);
		
		% taking care of the polarity of our signal
		vp.Handle_Polarity(polarityHandler);

		% hwo should we treat non finite elements (paraview cant handle them)
		switch nonFiniteHandler
			case 'error' % in this case we throw an error upon nonfinite elements
				if any(~isfinite(vp.volume.vol(:)))
					error('There were nonfinite elements in the volume');
				end
			case 'remove'
				nInf = sum(~isfinite(vp.volume.vol(:)));
				if nInf > 0
					pInf = nInf / vp.volume.nVoxel * 100;
					warnString = ['There were ', num2str(pInf), ' precent nonfin elements'];
					warning(warnString);
					vp.volume.vol(~isfinite(vp.volume.vol)) = 0;
				end
			case 'none'
				% do nothing about it
			otherwise
				error('Unknown option passed for our nonfinite handling');
		end

		% if requested, normalize volume between 0 and 1
		if flagNormalize
			vp.volume.vol = vp.volume.vol - vp.volume.minVol; % scale between 0 and 1
			vp.volume.vol = vp.volume.vol / vp.volume.maxVol;
		end

		if ~isempty(vp.volume.name)
			name = vp.volume.name; 
		else
			name = 'exportedDataset';
		end

		vtkwrite(... % actual export function
			datasetPath, ... % output path for vtk file
			'structured_points', ... % dataset type (for volumes use structured_points)
			name, ... % name of dataset in paraview
			permute(vp.volume.vol, [2, 3, 1]), ... % matlab 3d matrix
			'spacing', vp.volume.dX, vp.volume.dY, vp.volume.dZ, ... % spacing
			'origin', vp.volume.origin(2), vp.volume.origin(3), vp.volume.origin(1), ... % origin of dataset
			'BINARY');  % binary flag

		vp.VPrintf('done!\n');
	else
		error('Cannot export an nonexisting volume');
	end

end