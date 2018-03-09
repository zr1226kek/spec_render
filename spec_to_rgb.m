function rgb = spec_to_rgb(spec, varargin)
% This function convert a spectral distribution to a RGB color
% INPUT
%   spec:       n-by-2 matrix
% PARAMETERS
%   Space:      string: {'sRGB' (default)}
%   Method:     string: {'ShrinkToGray' (default), 'Clip', 'YoungsMethod', 
%               'SpektresMethod'}
%   Mix:        true | false (default)
%   MaxY:       scalar
% OUTPUT
%   rgb:        n-by-3 matrix, or
%               1-by-3 vector

assert(size(spec, 2) == 2);

parameters = handle_parameter(varargin);

switch parameters.method
    case {'youngsmethod', 'spektresmethod'}
        rgb = direct_convert(spec, parameters.method);
    otherwise
        xyz = spec_to_ciexyz(spec, 'CMFProfile', parameters.CMFProfile);
        if parameters.mix
            xyz = sum(xyz) / sum(xyz(:, 2)) * parameters.maxy;
        else
            xyz = xyz / max(xyz(:, 2)) * parameters.maxy;
        end
        rgb = ciexyz_to_rgb(xyz, 'space', parameters.space, 'method', parameters.method);
end
end

function parameters = handle_parameter(varg)
% Helper function

n = length(varg);
assert(mod(n, 2) == 0);

parameters.space = 'srgb';
parameters.method = 'shrinktogray';
parameters.mix = false;
parameters.maxy = 1;
parameters.CMFProfile = 'ciexyz31_1';

for i = 1:n/2
    key = lower(varg{i*2-1});
    value = varg{i*2};
    switch key
        case 'method'
            if ~ischar(value)
                error('The Method must be a string!');
            end
            parameters.method = lower(value);
        case 'mix'
            if ~islogical(value)
                error('The Mix must be a logical value!');
            end
            parameters.mix = value;
        case 'space'
            if ~ischar(value)
                error('The Space must be a string!');
            end
            parameters.space = lower(value);
        case 'maxy'
            if ~isnumeric(value)
                error('The MaxY must be a numeric value!');
            end
            parameters.maxy = value;
        case 'cmfprofile'
            if ~ischar(value)
                error('The CMFProfile must be a string!');
            end
            parameters.CMFProfile = value;
        otherwise
            error('Unknow parameter name!');
    end
end
end
