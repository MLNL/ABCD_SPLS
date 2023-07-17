function plot_weight_brain_subcortex(res, weight, fname)
% plot_weight_brain_subcortex
%
% Syntax:  plot_weight_brain_subcortex(res, weight, fname)
%
% # Inputs
% input1:: Description
% input2:: Description
% input3:: Description
%
% # Outputs
% output1:: Description
% output2:: Description
%
% # Example
%    Line 1 of example
%    Line 2 of example
%    Line 3 of example
%
%
% See also: [plot_check_perm](),  [plot_check_split]()
%
% Author: Agoston Mihalik
%
% Website: http://www.mlnl.cs.ucl.ac.uk/

% Set defaults
res = res_defaults(res, 'vbm', 'vbm.subcortex', 1);

% Load mask
maskfname = select_file(res, fullfile(res.dir.project, 'data'), 'Select mask file...', 'nii', res.vbm.file.mask);
hdr_mask = spm_vol(maskfname);
img_mask = spm_read_vols(hdr_mask);
img_mask(isnan(img_mask)) = 0;

% Create image from weight
img = zeros(hdr_mask.dim);
img(img_mask~=0) = weight;

% Normalize weight
minmax = max(abs(weight));
img = img ./ minmax;

% Remove cortical regions from weight
set_path('aal');
parcfname = select_file(res, pwd, 'Select atlas file...', 'any', which(res.vbm.file.atlas.img));
img_parc = spm_read_vols(spm_vol(parcfname));
img_parc(isnan(img_parc)) = 0;
parclabel_fname = select_file(res, pwd, 'Select atlas label file...', 'any', which(res.vbm.file.atlas.label));
T = readtable(parclabel_fname);
img(~ismember(img_parc, T.Index(ismember(T.Structure, 'Subcortex')))) = 0;

% Write weight on disc
hdr = struct('dim', hdr_mask.dim, 'dt', [spm_type('float32') spm_platform('bigend')], ...
    'mat', hdr_mask.mat, 'pinfo', [1 0 0]', 'n', [1 1], 'descrip', 'Image'); % header settings are important!!
hdr.fname = [fname '.nii'];
spm_write_vol(hdr, img);

% Visualize subcortex using nilearn
[version, executable, isloaded] = pyversion;
message = ['Using Python version ' version ' to plot subcortical regions.'];
disp(message);
set_path('fsl');
mnifname = select_file(res, pwd, 'Select MNI template file...', 'any', which(res.vbm.file.nilearn.MNI));
bg = py.nilearn.image.load_img(mnifname);
subcort_w = py.nilearn.image.load_img([fname '.nii']);
py.nilearn.plotting.plot_stat_map(subcort_w, pyargs('output_file', [fname '.svg'], 'bg_img', bg, ...
    'colorbar', 1, 'display_mode', 'ortho', 'cut_coords', [11 -19 13], ... % [28 13 -11]
    'cmap', 'jet', 'annotate', 1, 'black_bg', 0, 'symmetric_cbar', 1, 'vmax', 1)) % 'cut_coords', [-2,-6,-23],
% py.nilearn.plotting.plot_stat_map(subcort_w, pyargs('bg_img', bg, 'cut_coords', [-2,-6,-23],  'output_file', ...
% [fname{2} '.svg'], 'colorbar', 0, 'annotate', 0, 'draw_cross',0, 'black_bg', 0))
