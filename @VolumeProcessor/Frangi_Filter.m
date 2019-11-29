% File: Frangi_Filter.m @ VolumeProcessor
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 20.08.2019

% Description: Performs frangi filtering to enhance vessel structures
% in a reconstructed dataset.

function Frangi_Filter(vp, varargin)

	% default settings
	vesselRange = [20:50:500] * 1e-6; % size of vessels we want to filter for
	polarityHandler = 'abs';
	alpha = 0.5;
	beta = 0.5;

	for iargin=1:2:(nargin - 1)
		switch varargin{iargin}
			case 'alpha'
				alpha = varargin{iargin + 1};
			case 'beta'
				beta = varargin{iargin + 1};
			case vesselRange
				vesselRange = varargin{iargin+1};
			case 'polarityHandler'
				polarityHandler = varargin{iargin+1};
			otherwise
				error("Unknown option passed to Frangi_Filter");
		end
	end

	vp.VPrintf('Frangi filtering data... ', 1);
	vp.Handle_Polarity(polarityHandler);
	vp.volume.vol = vesselFilter(vp.volume.vol, [vp.volume.dZ, vp.volume.dX, vp.volume.dY], vesselRange);
	% scale should always be half of the target vessel size

	vp.VPrintf('done!\n', 0);
	
end
