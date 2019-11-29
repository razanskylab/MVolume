% File: Deconvolve.m @ VolumeProcessor
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 21.11.2019

% Description: Takes the volumetic image and deconvolves it with 
% the point spread function to reduce image blurring.

function Deconvolve(ws, varargin)
	
	% default settings
	method = 'blind';
	psf = [];
	nIter = 10;
	dampar = 0;
	polarityHandler = '';

	for iargin=1:2:(nargin-1)
		switch vararign{iargin}
			case 'nIter'
				nIter = varargin{iargin+1};
			case 'dampar'
				dampar = varargin{iargin+1};
			case 'psf'
				psf = varargin{iargin + 1};
			case 'polarityHandler'
				polarityHandler = varargin{iargin + 1};
			case 'method'
				method = varargin{iargin + 1};
			otherwise
				error('Never heard of such an option bro');
		end
	end
	ws.saftedVol = abs(ws.saftedVol);
	psf = abs(ws.usTransducer.Get_PSF(ws.dZ, ws.dX, ws.dY));

	nIter = 10; % can be very time consuming if high
	dampar = 0;

	% deblur image using blind deconvolution
	% psf guess is known
	switch ws.deconvMethod
		case 'lucy'
			% deblur image based on richard lucy deconvolution
			% psf known, noise unknown
			% https://de.mathworks.com/help/images/ref/deconvlucy.html#f1-535133
			ws.saftedVol = deconvlucy(ws.saftedVol, psf, nIter);
			% ws.saftedVol - input volume for deconvolution
			% psf - estimate of point spread function
			% nIter - number of iterations
			% dampar - damping to reduce noise amplification
		case 'blind'
			[ws.saftedVol, psfr] = deconvblind(ws.saftedVol, psf, nIter);
			% psfi: initial guess of point spread function
			% 		size of matrix strongly affects the outcome
		case 'wiener'
			% deblur image based on wiener filter algorithm
			% https://de.mathworks.com/help/images/ref/deconvwnr.html
			ws.saftedVol = deconvwnr(ws.saftedVol, psf);
		otherwise
			error('Unknown deconvolution method');
	end

	ws.VPrintf('done!\n', 0);
	toc

end
