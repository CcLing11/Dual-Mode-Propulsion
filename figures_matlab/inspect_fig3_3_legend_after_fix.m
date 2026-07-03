clear; clc;
figPath = 'E:\Grade2\双模小论文\IEEE_TAES_orig-research\figures_matlab\source_figs\fig3_3_mode_time_mass.fig';
hFig = openfig(figPath, 'new', 'invisible');
legs = findall(hFig, 'Type', 'legend');
for iLeg = 1:numel(legs)
    labels = get(legs(iLeg), 'String');
    fprintf('Legend %d:\n', iLeg);
    disp(labels);
end
close(hFig);
